import MAMapKit
import UIKit

/// 声明式绘制标记点的管理器
class MarkerManager {
    private weak var mapView: MAMapView?

    private var markers: [Marker] = [] {
        didSet {
            if regionClusteringOptions?.enabled ?? false {
                calculateClusterMarkers()
            }
        }
    }
    
    var regionClusteringOptions: RegionClusteringOptions? {
        didSet {
            if regionClusteringOptions?.enabled ?? false {
                calculateClusterMarkers()
            }
        }
    }
    private var regionClusterMarkers: RegionClusterMarkers = RegionClusterMarkers()

    init(mapView: MAMapView) {
        self.mapView = mapView
    }

    func setMarkers(_ markers: [Marker]) {
        guard let mapView = mapView else { return }

        // 保存新的 markers
        let newMarkers = markers
        let oldMarkersMap = Dictionary(uniqueKeysWithValues: self.markers.map { ($0.id, $0) })
        self.markers = newMarkers

        // 当前地图上已有的 SSAnnotation
        let oldAnnotations = mapView.annotations.compactMap { $0 as? SSAnnotation }
        let oldAnnotationsMap = Dictionary(uniqueKeysWithValues: oldAnnotations.map { ($0.id, $0) })

        var annotationsToAdd: [SSAnnotation] = []
        var annotationsToRemove: [SSAnnotation] = []

        // 对比新增/更新
        for marker in newMarkers {
            if let oldMarker = oldMarkersMap[marker.id],
                let oldAnnotation = oldAnnotationsMap[marker.id]
            {
                // id 一致，检查属性是否变化
                let coordinateChanged =
                    oldMarker.coordinate.latitude != marker.coordinate.latitude
                    || oldMarker.coordinate.longitude != marker.coordinate.longitude
                let titleChanged =
                    oldMarker.title != marker.title || oldMarker.subtitle != marker.subtitle
                let imageChanged =
                    oldMarker.image?.url != marker.image?.url
                    || oldMarker.image?.size.width != marker.image?.size.width
                    || oldMarker.image?.size.height != marker.image?.size.height
                let zIndexChanged = oldMarker.zIndex != marker.zIndex
                let centerOffsetChanged =
                    oldMarker.centerOffset?.x != marker.centerOffset?.x
                    || oldMarker.centerOffset?.y != marker.centerOffset?.y
                let calloutOffsetChanged =
                    oldMarker.calloutOffset?.x != marker.calloutOffset?.x
                    || oldMarker.calloutOffset?.y != marker.calloutOffset?.y
                let textOffsetChanged =
                    oldMarker.textOffset?.x != marker.textOffset?.x
                    || oldMarker.textOffset?.y != marker.textOffset?.y
                let enabledChanged = oldMarker.enabled != marker.enabled
                let highlightedChanged = oldMarker.highlighted != marker.highlighted
                let canShowCalloutChanged = oldMarker.canShowCallout != marker.canShowCallout
                let draggableChanged = oldMarker.draggable != marker.draggable
                let canAdjustChanged = oldMarker.canAdjustPosition != marker.canAdjustPosition
                let textStyleChanged =
                    oldMarker.textStyle?.color != marker.textStyle?.color
                    || oldMarker.textStyle?.fontSize != marker.textStyle?.fontSize
                    || oldMarker.textStyle?.fontWeight != marker.textStyle?.fontWeight
                    || oldMarker.textStyle?.numberOfLines != marker.textStyle?.numberOfLines
                let pinColorChanged = oldMarker.pinColor != marker.pinColor

                if coordinateChanged || titleChanged || imageChanged || zIndexChanged
                    || centerOffsetChanged || calloutOffsetChanged || textOffsetChanged
                    || enabledChanged || highlightedChanged || canShowCalloutChanged
                    || draggableChanged || canAdjustChanged || textStyleChanged || pinColorChanged
                {

                    // 更新已有 Annotation
                    if let view = mapView.view(for: oldAnnotation) as? TextAnnotationView {
                        // 坐标
                        if coordinateChanged {
                            oldAnnotation.coordinate = CLLocationCoordinate2D(
                                latitude: marker.coordinate.latitude,
                                longitude: marker.coordinate.longitude
                            )
                        }

                        // title/subtitle
                        if titleChanged {
                            view.setText(marker.title ?? oldAnnotation.title)
                            oldAnnotation.title = marker.title
                            oldAnnotation.subtitle = marker.subtitle
                        }

                        // zIndex
                        if zIndexChanged, let z = marker.zIndex {
                            view.zIndex = z
                            mapView.reactZIndexSortedSubviews()
                        }

                        // center/callout/text offsets
                        if let co = marker.centerOffset, centerOffsetChanged {
                            view.centerOffset = CGPoint(x: co.x, y: co.y)
                        }
                        if let co = marker.calloutOffset, calloutOffsetChanged {
                            view.calloutOffset = CGPoint(x: co.x, y: co.y)
                        }
                        if let to = marker.textOffset, textOffsetChanged {
                            view.textOffset = CGPoint(x: to.x, y: to.y)
                            view.layoutSubviews()
                        }

                        // enabled/highlighted/callout/draggable/adjust
                        if enabledChanged { view.isEnabled = marker.enabled ?? true }
                        if highlightedChanged {
                            view.isHighlighted = marker.highlighted ?? false
                            view.setNeedsDisplay()
                            view.layoutIfNeeded()
                        }
                        if canShowCalloutChanged {
                            view.canShowCallout = marker.canShowCallout ?? true
                            view.setNeedsDisplay()
                            view.layoutIfNeeded()
                        }
                        if draggableChanged { view.isDraggable = marker.draggable ?? false }
                        if canAdjustChanged {
                            view.canAdjustPositon = marker.canAdjustPosition ?? false
                        }

                        if textStyleChanged, let style = marker.textStyle { view.textStyle = style }

                        // 图片
                        if imageChanged, let url = marker.image?.url {
                            Task { [weak view] in
                                let uiImage = await ImageLoader.from(url)
                                let cgSize = CGSize(
                                    width: marker.image?.size.width ?? 0,
                                    height: marker.image?.size.height ?? 0)
                                let resized = uiImage?.resized(to: cgSize)
                                DispatchQueue.main.async {
                                    view?.setImage(resized, url: url, size: cgSize)
                                }
                            }
                        }
                    }
                }
            } else {
                // 新增标注
                let annotation = SSAnnotation(
                    id: marker.id,
                    coordinate: CLLocationCoordinate2D(
                        latitude: marker.coordinate.latitude,
                        longitude: marker.coordinate.longitude),
                    title: marker.title,
                    subtitle: marker.subtitle
                )
                annotationsToAdd.append(annotation)
            }
        }

        // 删除旧标注
        let newIds = Set(newMarkers.map { $0.id })
        annotationsToRemove = oldAnnotations.filter { !newIds.contains($0.id) }

        // 更新地图
        mapView.removeAnnotations(annotationsToRemove)
        mapView.addAnnotations(annotationsToAdd)
    }

    func getMarker(id: String) -> Marker? {
        markers.first { marker in
            marker.id == id
        }
    }
    
    func setRegionClusteringOptions(_ options: RegionClusteringOptions) {
        regionClusteringOptions = options
    }
    
    func calculateClusterMarkers() {
        guard let options = regionClusteringOptions else {
            regionClusterMarkers = RegionClusterMarkers()
            return
        }
        guard let mapView = mapView else { return }
        
        for rule in options.rules {
            let grouped = Dictionary(grouping: markers, by: { marker in
                if rule.by == "province" {
                    return marker.extra?.province
                } else if rule.by == "city" {
                    return marker.extra?.city
                } else if rule.by == "district" {
                    return marker.extra?.district
                }
                return marker.extra?.province
            })
            for (regionId, markersInRegion) in grouped {
                guard !markersInRegion.isEmpty, let regionId = regionId else { continue }
                
                let lat = markersInRegion.map { $0.coordinate.latitude }.reduce(0, +) / Double(markersInRegion.count)
                let lon = markersInRegion.map { $0.coordinate.longitude }.reduce(0, +) / Double(markersInRegion.count)
                
                let cluster = ClusterMarker(
                    id: "\(regionId),\(lat),\(lon)",
                    coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                    count: markersInRegion.count,
                    markers: markersInRegion
                )
                
                if rule.by == "province" {
                    regionClusterMarkers.provinceClusterMarkers.append(cluster)
                } else if rule.by == "city" {
                    regionClusterMarkers.cityClusterMarkers.append(cluster)
                } else if rule.by == "district" {
                    regionClusterMarkers.districtClusterMarkers.append(cluster)
                }
            }
        }
    }
}

struct RegionClusterMarkers {
    var provinceClusterMarkers: [ClusterMarker] = []
    var cityClusterMarkers: [ClusterMarker] = []
    var districtClusterMarkers: [ClusterMarker] = []
}

struct ClusterMarker {
    let id: String         // 聚合 ID，可以用行政区 ID
    let coordinate: CLLocationCoordinate2D
    let count: Int         // 该聚合包含的原始点数量
    let markers: [Marker]  // 原始点集合
}

class SSAnnotation: NSObject, MAAnnotation {
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

class TextAnnotationView: MAAnnotationView {

    private let textLabel = UILabel()

    var textStyle: TextStyle? = nil {
        didSet {
            updateTextStyle()
        }
    }
    var textOffset: CGPoint? = .zero {
        didSet {
            positionLabel()
        }
    }

    var currentImageURL: String?

    override init(annotation: MAAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        addSubview(textLabel)
        bringSubviewToFront(textLabel)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setImage(_ image: UIImage?, url: String?, size: CGSize? = nil) {
        let needsUpdate = currentImageURL != url || image?.size != self.image?.size
        guard needsUpdate else { return }

        self.image = image
        if let size = size {
            self.frame.size = size
        }
        currentImageURL = url
        setNeedsLayout()
        layoutIfNeeded()
    }

    func setText(_ text: String?) {
        textLabel.text = text
        textLabel.sizeToFit()
        positionLabel()
        bringSubviewToFront(textLabel)
    }

    private func updateTextStyle() {
        textLabel.textAlignment = .center
        if let textStyle = textStyle {
            if let hex = textStyle.color { textLabel.textColor = UIColor(hex: hex) }
            textLabel.font = UIFont.systemFont(
                ofSize: textStyle.fontSize ?? 17,
                weight: UIFont.Weight(string: textStyle.fontWeight ?? "") ?? .regular)
            textLabel.numberOfLines = textStyle.numberOfLines ?? 1
        } else {
            textLabel.font = .systemFont(ofSize: 14, weight: .medium)
            textLabel.textColor = .white
        }
        textLabel.sizeToFit()
        textLabel.setNeedsLayout()
        textLabel.layoutIfNeeded()
    }

    private func positionLabel() {
        textLabel.center = CGPoint(
            x: bounds.width / 2 + (textOffset?.x ?? 0),
            y: bounds.height / 2 + (textOffset?.y ?? 0)
        )
    }

    override var image: UIImage? {
        didSet { setNeedsLayout() }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        positionLabel()
        bringSubviewToFront(textLabel)
    }
}

///// 四叉树节点
//class QuadTreeNode {
//    let boundingBox: CGRect
//    var points: [Marker] = []
//    var children: [QuadTreeNode]? = nil
//    let maxPoints = 4
//
//    init(boundingBox: CGRect) {
//        self.boundingBox = boundingBox
//    }
//
//    func insert(_ marker: Marker) {
//        guard
//            boundingBox.contains(
//                CGPoint(x: marker.coordinate.longitude, y: marker.coordinate.latitude))
//        else { return }
//        if points.count < maxPoints {
//            points.append(marker)
//        } else {
//            if children == nil { subdivide() }
//            children?.forEach { $0.insert(marker) }
//        }
//    }
//
//    private func subdivide() {
//        let midX = boundingBox.midX
//        let midY = boundingBox.midY
//        let minX = boundingBox.minX
//        let minY = boundingBox.minY
//        let maxX = boundingBox.maxX
//        let maxY = boundingBox.maxY
//
//        children = [
//            QuadTreeNode(
//                boundingBox: CGRect(x: minX, y: minY, width: midX - minX, height: midY - minY)),
//            QuadTreeNode(
//                boundingBox: CGRect(x: midX, y: minY, width: maxX - midX, height: midY - minY)),
//            QuadTreeNode(
//                boundingBox: CGRect(x: minX, y: midY, width: midX - minX, height: maxY - midY)),
//            QuadTreeNode(
//                boundingBox: CGRect(x: midX, y: midY, width: maxX - midX, height: maxY - midY)),
//        ]
//        // 将现有点分配给子节点
//        points.forEach { p in children?.forEach { $0.insert(p) } }
//        points.removeAll()
//    }
//
//    func query(in rect: CGRect) -> [Marker] {
//        if !boundingBox.intersects(rect) { return [] }
//        var result = points.filter {
//            rect.contains(CGPoint(x: $0.coordinate.longitude, y: $0.coordinate.latitude))
//        }
//        children?.forEach { result.append(contentsOf: $0.query(in: rect)) }
//        return result
//    }
//}
