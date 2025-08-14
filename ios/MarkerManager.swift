import MAMapKit
import UIKit

/// 声明式绘制标记点的管理器
class MarkerManager {
    private weak var mapView: MAMapView?
    
    private var markers: [Marker] = []

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

        // 1️⃣ 对比新增/更新
        for marker in newMarkers {
            if let oldMarker = oldMarkersMap[marker.id],
               let oldAnnotation = oldAnnotationsMap[marker.id] {
                // id 一致，检查属性是否变化
                let coordinateChanged = oldMarker.coordinate.latitude != marker.coordinate.latitude || oldMarker.coordinate.longitude != marker.coordinate.longitude
                let titleChanged = oldMarker.title != marker.title || oldMarker.subtitle != marker.subtitle
                let imageChanged = oldMarker.image?.url != marker.image?.url
                let zIndexChanged = oldMarker.zIndex != marker.zIndex
                let centerOffsetChanged = oldMarker.centerOffset?.x != marker.centerOffset?.x || oldMarker.centerOffset?.y != marker.centerOffset?.y
                let calloutOffsetChanged = oldMarker.calloutOffset?.x != marker.calloutOffset?.x || oldMarker.calloutOffset?.y != marker.calloutOffset?.y
                let textOffsetChanged = oldMarker.textOffset?.x != marker.textOffset?.x || oldMarker.textOffset?.y != marker.textOffset?.y
                let enabledChanged = oldMarker.enabled != marker.enabled
                let highlightedChanged = oldMarker.highlighted != marker.highlighted
                let canShowCalloutChanged = oldMarker.canShowCallout != marker.canShowCallout
                let draggableChanged = oldMarker.draggable != marker.draggable
                let canAdjustChanged = oldMarker.canAdjustPosition != marker.canAdjustPosition
                let textStyleChanged = oldMarker.textStyle?.color != marker.textStyle?.color || oldMarker.textStyle?.fontSize != marker.textStyle?.fontSize || oldMarker.textStyle?.fontWeight != marker.textStyle?.fontWeight || oldMarker.textStyle?.numberOfLines != marker.textStyle?.numberOfLines
                let pinColorChanged = oldMarker.pinColor != marker.pinColor

                if coordinateChanged || titleChanged || imageChanged || zIndexChanged ||
                   centerOffsetChanged || calloutOffsetChanged || textOffsetChanged ||
                   enabledChanged || highlightedChanged || canShowCalloutChanged ||
                   draggableChanged || canAdjustChanged || textStyleChanged || pinColorChanged {

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
                        }

                        // zIndex
                        if zIndexChanged, let z = marker.zIndex { view.zIndex = z }

                        // center/callout/text offsets
                        if let co = marker.centerOffset, centerOffsetChanged { view.centerOffset = CGPoint(x: co.x, y: co.y) }
                        if let co = marker.calloutOffset, calloutOffsetChanged { view.calloutOffset = CGPoint(x: co.x, y: co.y) }
                        if let to = marker.textOffset, textOffsetChanged { view.textOffset = CGPoint(x: to.x, y: to.y); view.layoutSubviews() }

                        // enabled/highlighted/callout/draggable/adjust
                        if enabledChanged { view.isEnabled = marker.enabled ?? true }
                        if highlightedChanged { view.isHighlighted = marker.highlighted ?? false }
                        if canShowCalloutChanged { view.canShowCallout = marker.canShowCallout ?? true }
                        if draggableChanged { view.isDraggable = marker.draggable ?? false }
                        if canAdjustChanged { view.canAdjustPositon = marker.canAdjustPosition ?? false }

                        if textStyleChanged, let style = marker.textStyle { view.textStyle = style }

                        // 图片
                        if imageChanged, let url = marker.image?.url {
                            Task { [weak view] in
                                let uiImage = await ImageLoader.from(url)
                                let resized = uiImage?.resized(to: CGSize(width: marker.image?.size.width ?? 0,
                                                                          height: marker.image?.size.height ?? 0))
                                DispatchQueue.main.async {
                                    view?.setImage(resized, url: url)
                                }
                            }
                        }
                    }
                }
            } else {
                // 新增标注
                let annotation = SSAnnotation(
                    id: marker.id,
                    coordinate: CLLocationCoordinate2D(latitude: marker.coordinate.latitude,
                                                       longitude: marker.coordinate.longitude),
                    title: marker.title,
                    subtitle: marker.subtitle
                )
                annotationsToAdd.append(annotation)
            }
        }

        // 2️⃣ 删除旧标注
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
    
    var textStyle: TextStyle? {
        didSet {
            updateTextStyle()
        }
    }
    var textOffset: CGPoint {
        didSet {
            positionLabel()
        }
    }
    
    var currentImageURL: String?

    init(annotation: MAAnnotation?, reuseIdentifier: String?, textStyle: TextStyle?, textOffset: CGPoint = .zero) {
        self.textStyle = textStyle
        self.textOffset = textOffset
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        addSubview(textLabel)
        bringSubviewToFront(textLabel)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func setImage(_ image: UIImage?, url: String?) {
        guard currentImageURL != url else { return }
        self.image = image
        currentImageURL = url
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
            textLabel.font = UIFont.systemFont(ofSize: textStyle.fontSize ?? 17,
                                               weight: UIFont.Weight(string: textStyle.fontWeight ?? "") ?? .regular)
            textLabel.numberOfLines = textStyle.numberOfLines ?? 1
        } else {
            textLabel.font = .systemFont(ofSize: 14, weight: .medium)
            textLabel.textColor = .white
        }
    }

    private func positionLabel() {
        textLabel.center = CGPoint(
            x: bounds.width / 2 + textOffset.x,
            y: bounds.height / 2 + textOffset.y
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
