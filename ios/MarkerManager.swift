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
        let oldMarkers = self.markers
        self.markers = markers
        applyDiff(old: oldMarkers, new: markers)
        calculateClusterMarkers()
    }

    private func applyDiff(old oldMarkers: [Marker], new newMarkers: [Marker]) {
        guard let mapView = mapView else { return }
        
        let oldAnnotations = mapView.annotations.compactMap { $0 as? SSAnnotation }
        
        let diff = diffItems(oldItems: oldMarkers, newItems: newMarkers, isSame: { $0.id == $1.id && $0.style == $1.style }, changes: markerChanges)
        
        print("Diff: \(diff.toAdd.count)个新增")
        print("Diff: \(diff.toUpdate.count)个更新")
        print("Diff: \(diff.toRemove.count)个删除")
        
        let toRemoveIds = diff.toRemove.map { $0.id }
        let toRemoveAnnotations = oldAnnotations.filter { toRemoveIds.contains($0.id) }
        mapView.removeAnnotations(toRemoveAnnotations)
        
        for update in diff.toUpdate {
            guard
                let annotation = oldAnnotations.first(where: { $0.id == update.old.id }),
                let view = mapView.view(for: annotation)
            else { return }
            updateAnnotation(annotation: annotation, view: view, changes: update.changes)
        }
        
        let toAddAnnotations = diff.toAdd.map { marker in
            return SSAnnotation(id: marker.id, coordinate: CLLocationCoordinate2D(latitude: marker.coordinate.latitude, longitude: marker.coordinate.longitude), title: marker.title, subtitle: marker.subtitle)
        }
        mapView.addAnnotations(toAddAnnotations)
    }

    private func updateAnnotation(annotation: SSAnnotation, view: MAAnnotationView, changes: [FieldChange]) {
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

class ClusterAnnotation: SSAnnotation {
    var count: Int = 0
    var by: String?
    
    init(id: String, coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?, count: Int, by: String) {
        super.init(id: id, coordinate: coordinate, title: title, subtitle: subtitle)
        self.count = count
        self.title = title
        self.by = by
    }
}

class TextAnnotationView: MAAnnotationView {

    private let textLabel = PaddedLabel()
    
    var textStyle: TextStyle? {
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

    private let minTouchSize: CGSize = CGSize(width: 44, height: 44)

    override init(annotation: MAAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        addSubview(textLabel)
        bringSubviewToFront(textLabel)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - 设置图片
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

    // MARK: - 设置文本
    func setText(_ text: String?) {
        print("TextAnnotationView：设置文本内容：\(text ?? "")")
        textLabel.text = text
        textLabel.invalidateIntrinsicContentSize()
        textLabel.sizeToFit()
        updateFrameForLabel()
        positionLabel()
        bringSubviewToFront(textLabel)
        
        updateTextStyle()
    }

    // MARK: - 样式更新
    private func updateTextStyle() {
        print("TextAnnotationView：更新文本样式")
        textLabel.textAlignment = .center

        if let style = textStyle {
            if let hex = style.color { textLabel.textColor = UIColor(hex: hex) }
            textLabel.font = UIFont.systemFont(
                ofSize: style.fontSize ?? 17,
                weight: UIFont.Weight(string: style.fontWeight ?? "") ?? .regular
            )
            textLabel.numberOfLines = style.numberOfLines ?? 1

            if let padding = style.padding {
                textLabel.padding = UIEdgeInsets(top: padding.y, left: padding.x, bottom: padding.y, right: padding.x)
            }
            if let bgHex = style.backgroundColor {
                textLabel.backgroundColor = UIColor(hex: bgHex)
            }
        } else {
            // 默认样式
            textLabel.font = .systemFont(ofSize: 14, weight: .medium)
            textLabel.textColor = .white
            textLabel.padding = UIEdgeInsets(top: 4, left: 6, bottom: 4, right: 6)
            textLabel.backgroundColor = UIColor(hex: "#5981D8")
        }

        textLabel.layer.cornerRadius = 6
        textLabel.layer.cornerCurve = .continuous
        textLabel.layer.masksToBounds = true

        // 更新布局
        textLabel.invalidateIntrinsicContentSize()
        textLabel.sizeToFit()
        updateFrameForLabel()
        positionLabel()
        textLabel.setNeedsLayout()
        textLabel.layoutIfNeeded()
    }

    // MARK: - 更新 annotation view frame 以包含 label
    private func updateFrameForLabel() {
        let labelSize = textLabel.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
        self.frame.size = CGSize(
            width: max(labelSize.width, self.frame.width),
            height: max(labelSize.height, self.frame.height)
        )
    }

    // MARK: - 定位文本
    private func positionLabel() {
        textLabel.center = CGPoint(
            x: bounds.width / 2 + (textOffset?.x ?? 0),
            y: bounds.height / 2 + (textOffset?.y ?? 0)
        )
    }

    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        positionLabel()
        bringSubviewToFront(textLabel)
    }

    override var image: UIImage? {
        didSet { setNeedsLayout() }
    }

    // MARK: - 扩展触摸判定
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let labelFrame = textLabel.frame.insetBy(dx: -textLabel.padding.left, dy: -textLabel.padding.top)
        let imageFrame = self.image != nil ? self.bounds : .zero
        var touchFrame = labelFrame.union(imageFrame)

        if touchFrame.width < minTouchSize.width { touchFrame.size.width = minTouchSize.width }
        if touchFrame.height < minTouchSize.height { touchFrame.size.height = minTouchSize.height }

        return touchFrame.contains(point)
    }
}

class PaddedLabel: UILabel {
    var padding: UIEdgeInsets = UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4)

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + padding.left + padding.right,
            height: size.height + padding.top + padding.bottom
        )
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let originalSize = super.sizeThatFits(CGSize(width: size.width - padding.left - padding.right,
                                                     height: size.height - padding.top - padding.bottom))
        return CGSize(
            width: originalSize.width + padding.left + padding.right,
            height: originalSize.height + padding.top + padding.bottom
        )
    }
}

func markerChanges(old: Marker, new: Marker) -> [FieldChange] {
    var changes: [FieldChange] = []
    
    if old.coordinate.latitude != new.coordinate.latitude || old.coordinate.longitude != new.coordinate.longitude {
        changes.append(FieldChange(key: "coordinate", oldValue: old.coordinate, newValue: new.coordinate))
    }
    if old.title != new.title {
        changes.append(FieldChange(key: "title", oldValue: old.title, newValue: new.title))
    }
    if old.subtitle != new.subtitle {
        changes.append(FieldChange(key: "subtitle", oldValue: old.subtitle, newValue: new.subtitle))
    }
    if old.centerOffset?.x != new.centerOffset?.x || old.centerOffset?.y != new.centerOffset?.y {
        changes.append(FieldChange(key: "centerOffset", oldValue: old.centerOffset, newValue: new.centerOffset))
    }
    if old.calloutOffset?.x != new.calloutOffset?.x || old.calloutOffset?.y != new.calloutOffset?.y {
        changes.append(FieldChange(key: "calloutOffset", oldValue: old.calloutOffset, newValue: new.calloutOffset))
    }
    if old.textOffset?.x != new.textOffset?.x || old.textOffset?.y != new.textOffset?.y {
        changes.append(FieldChange(key: "textOffset", oldValue: old.textOffset, newValue: new.textOffset))
    }
    if old.image?.url != new.image?.url || old.image?.size.width != new.image?.size.width || old.image?.size.height != new.image?.size.height {
        changes.append(FieldChange(key: "image", oldValue: old.image, newValue: new.image))
    }
    if old.textStyle?.color != new.textStyle?.color || old.textStyle?.fontSize != new.textStyle?.fontSize || old.textStyle?.fontWeight != new.textStyle?.fontWeight || old.textStyle?.numberOfLines != new.textStyle?.numberOfLines || old.textStyle?.backgroundColor != new.textStyle?.backgroundColor || old.textStyle?.padding?.x != new.textStyle?.padding?.x || old.textStyle?.padding?.y != new.textStyle?.padding?.y {
        changes.append(FieldChange(key: "textStyle", oldValue: old.textStyle, newValue: new.textStyle))
    }
    if old.pinColor != new.pinColor {
        changes.append(FieldChange(key: "pinColor", oldValue: old.pinColor, newValue: new.pinColor))
    }
    if old.enabled != new.enabled {
        changes.append(FieldChange(key: "enabled", oldValue: old.enabled, newValue: new.enabled))
    }
    if old.highlighted != new.highlighted {
        changes.append(FieldChange(key: "highlighted", oldValue: old.highlighted, newValue: new.highlighted))
    }
    if old.canShowCallout != new.canShowCallout {
        changes.append(FieldChange(key: "canShowCallout", oldValue: old.canShowCallout, newValue: new.canShowCallout))
    }
    if old.draggable != new.draggable {
        changes.append(FieldChange(key: "draggable", oldValue: old.draggable, newValue: new.draggable))
    }
    if old.canAdjustPosition != new.canAdjustPosition {
        changes.append(FieldChange(key: "canAdjustPosition", oldValue: old.canAdjustPosition, newValue: new.canAdjustPosition))
    }
    if old.extra?.province != new.extra?.province || old.extra?.district != new.extra?.district || old.extra?.city != new.extra?.city {
        changes.append(FieldChange(key: "extra", oldValue: old.extra, newValue: new.extra))
    }
    
    return changes
}
