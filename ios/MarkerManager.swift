import ExpoModulesCore
import MAMapKit
import UIKit

/// 声明式绘制标记点的管理器
class MarkerManager {
    private weak var mapView: MAMapView?

    private var markers: [Marker] = []

    var regionClusteringOptions: RegionClusteringOptions?

    init(mapView: MAMapView) {
        self.mapView = mapView
    }

    func getMarker(id: String) -> Marker? {
        markers.first { marker in
            marker.id == id
        }
    }

    func setMarkers(_ markers: [Marker]) {
        for marker in markers {
            if let tag = marker.customCalloutViewTag {
                print(tag)
            }
        }
        let oldMarkers = self.markers
        self.markers = markers
        applyDiff(old: oldMarkers, new: markers)
        calculateClusterMarkers()
    }

    private func applyDiff(old oldMarkers: [Marker], new newMarkers: [Marker]) {
        guard let mapView = mapView else { return }
        
        let oldAnnotations = mapView.annotations.compactMap { $0 as? MyAnnotation }
        
        let diff = diffItems(oldItems: oldMarkers, newItems: newMarkers, isSame: { $0.id == $1.id && $0.style == $1.style }, changes: markerChanges)

        print("Diff: \(diff.toAdd.count)个新增")
        print("Diff: \(diff.toUpdate.count)个更新")
        print("Diff: \(diff.toRemove.count)个删除")

        // 删除
        let toRemoveIds = diff.toRemove.map { $0.id }
        let toRemoveAnnotations = oldAnnotations.filter { toRemoveIds.contains($0.id) }
        mapView.removeAnnotations(toRemoveAnnotations)

        // 更新
        for update in diff.toUpdate {
            guard
                let annotation = oldAnnotations.first(where: { $0.id == update.old.id }),
                let view = mapView.view(for: annotation)
            else { return }
            updateAnnotation(annotation: annotation, view: view, changes: update.changes)
        }

        // 添加
        let toAddAnnotations = diff.toAdd.map { marker in
            return MyAnnotation(id: marker.id, coordinate: CLLocationCoordinate2D(latitude: marker.coordinate.latitude, longitude: marker.coordinate.longitude), title: marker.title, subtitle: marker.subtitle)
        }
        mapView.addAnnotations(toAddAnnotations)
    }

    private func updateAnnotation(annotation: MyAnnotation, view: MAAnnotationView, changes: [FieldChange]) {
        for change in changes {
            if change.key == "coordinate", let newValue = change.newValue as? Coordinate {
                annotation.coordinate = CLLocationCoordinate2D(latitude: newValue.latitude, longitude: newValue.longitude)
                print("更新了坐标")
            }
            if change.key == "title", let newValue = change.newValue as? String {
                annotation.title = newValue
                print("更新了标题")
            }
            if change.key == "subtitle", let newValue = change.newValue as? String {
                annotation.subtitle = newValue
                print("更新了副标题")
            }
            if change.key == "centerOffset", let newValue = change.newValue as? Point {
                view.centerOffset = CGPoint(x: newValue.x, y: newValue.y)
                print("更新了centerOffset")
            }
            if change.key == "calloutOffset", let newValue = change.newValue as? Point {
                view.calloutOffset = CGPoint(x: newValue.x, y: newValue.y)
                print("更新了calloutOffset")
            }
            if change.key == "enabled", let newValue = change.newValue as? Bool {
                view.isEnabled = newValue
                print("更新了enabled")
            }
            if change.key == "highlighted", let newValue = change.newValue as? Bool {
                view.isHighlighted = newValue
                print("更新了highlighted")
            }
            if change.key == "canShowCallout", let newValue = change.newValue as? Bool {
                view.canShowCallout = newValue
                print("更新了canShowCallout")
            }
            if change.key == "draggable", let newValue = change.newValue as? Bool {
                view.isDraggable = newValue
                print("更新了draggable")
            }
            if change.key == "canAdjustPosition", let newValue = change.newValue as? Bool {
                view.canAdjustPositon = newValue
                print("更新了canAdjustPosition")
            }
        }

        if let view = view as? MAPinAnnotationView {
            for change in changes {
                if change.key == "pinColor", let newValue = change.newValue as? String {
                    if newValue == "red" {
                        view.pinColor = .red
                    } else if newValue == "green" {
                        view.pinColor = .green
                    } else if newValue == "purple" {
                        view.pinColor = .purple
                    }
                    print("更新了pinColor")
                }
            }
        } else if let view = view as? TextAnnotationView {
            for change in changes {
                if change.key == "textOffset", let newValue = change.newValue as? Point {
                    view.textOffset = CGPoint(x: newValue.x, y: newValue.y)
                    print("更新了textOffset")
                }
                if change.key == "image", let newValue = change.newValue as? MarkerImage {
                    Task { [weak view] in
                        let uiImage = await ImageLoader.from(newValue.url)
                        let cgSize = CGSize(width: newValue.size.width, height: newValue.size.height)
                        let resized = uiImage?.resized(to: cgSize)
                        DispatchQueue.main.async {
                            view?.setImage(resized, url: newValue.url, size: cgSize)
                        }
                    }
                    print("更新了image")
                }
                if change.key == "textStyle", let newValue = change.newValue as? TextStyle {
                    view.textStyle = newValue
                    print("更新了textStyle")
                }
            }
        } else if let view = view as? TeardropAnnotationView {
            for change in changes {
                if change.key == "teardropLabel", let newValue = change.newValue as? String {
                    view.label = newValue
                }
                if change.key == "teardropRandomFillColorSeed" {
                    if let newValue = change.newValue as? String {
                        view.teardrop.fillColor = UIColor.random(seed: newValue)
                    } else {
                        view.teardrop.fillColor = UIColor(hex: "#5981D8")
                    }
                }
                if change.key == "teardropFillColor", let newValue = change.newValue as? String {
                    view.teardrop.fillColor = UIColor(hex: newValue)
                }
            }
        }
    }

    func setRegionClusteringOptions(_ options: RegionClusteringOptions) {
        regionClusteringOptions = options
        calculateClusterMarkers()
    }

    func calculateClusterMarkers() {
        guard let options = regionClusteringOptions, options.enabled ?? false else { return }
        guard let mapView = mapView else { return }

        // 获取已有 clusterAnnotations
        var existingClusters = Dictionary(
            uniqueKeysWithValues: mapView.annotations.compactMap { $0 as? ClusterAnnotation }.map { ($0.id, $0) }
        )

        for rule in options.rules {
            // 按分组字段分组
            let grouped = Dictionary(grouping: markers, by: { marker in
                switch rule.by {
                case "province":
                    return marker.extra?.province ?? "未知省份"
                case "city":
                    return marker.extra?.city ?? "未知城市"
                case "district":
                    return marker.extra?.district ?? "未知区"
                default:
                    return marker.extra?.province ?? "未知"
                }
            })

            for (regionId, markersInRegion) in grouped {
                guard !markersInRegion.isEmpty else { continue }

                // 计算平均经纬度
                let lat = markersInRegion.map { $0.coordinate.latitude }.reduce(0, +) / Double(markersInRegion.count)
                let lon = markersInRegion.map { $0.coordinate.longitude }.reduce(0, +) / Double(markersInRegion.count)

                let clusterId = "\(rule.by)_\(regionId)"
                if let existing = existingClusters[clusterId] {
                    // 平滑更新 title/count/coordinate
                    existing.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    existing.title = "\(regionId) \(markersInRegion.count)"
                    existing.count = markersInRegion.count
                    existing.by = rule.by
                    
                    if let view = mapView.view(for: existing) as? TextAnnotationView {
                        view.setText(existing.title)
                    }
                    // 移除已处理的 annotation
                    existingClusters.removeValue(forKey: clusterId)
                } else {
                    // 新增 clusterAnnotation
                    let annotation = ClusterAnnotation(
                        id: clusterId,
                        coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                        title: "\(regionId) \(markersInRegion.count)",
                        subtitle: "",
                        count: markersInRegion.count,
                        by: rule.by
                    )
                    mapView.addAnnotation(annotation)
                }
            }
        }

        // 移除不再存在的 clusterAnnotation
        mapView.removeAnnotations(existingClusters.values.map { $0 })
    }
}

class MyAnnotation: NSObject, MAAnnotation {
    var id: String

    var title: String?
    var subtitle: String?

    dynamic var coordinate: CLLocationCoordinate2D {
        willSet {
            willChangeValue(forKey: "coordinate")
        }
        didSet {
            didChangeValue(forKey: "coordinate")
        }
    }

    init(id: String, coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?) {
        self.id = id
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}

class ClusterAnnotation: MyAnnotation {
    var count: Int = 0
    var by: String?
    
    init(id: String, coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?, count: Int, by: String) {
        super.init(id: id, coordinate: coordinate, title: title, subtitle: subtitle)
        self.count = count
        self.title = title
        self.by = by
    }
}
