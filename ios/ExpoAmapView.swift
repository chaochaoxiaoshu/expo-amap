import AMapFoundationKit
import AMapLocationKit
import AMapSearchKit
import ExpoModulesCore
import MAMapKit

class MapView: ExpoView {
    let mapView = MAMapView()

    var regionToSet: Region?

    private var markerManager: MarkerManager!
    private var polylineManager: PolylineManager!

    private var userTrackingMode: MAUserTrackingMode = .none

    private let onLoad = EventDispatcher()
    private let onZoom = EventDispatcher()
    private let onRegionChanged = EventDispatcher()
    private let onTapMarker = EventDispatcher()

    private let setCenterHandler = PromiseDelegateHandler<Void>()

    required init(appContext: AppContext? = nil) {
        super.init(appContext: appContext)
        clipsToBounds = true
        setupMapView()
        initMarkerManager()
        initPolylineManager()

        onLoad([
            "message": "Map loaded successfully",
            "timestamp": Date().timeIntervalSince1970,
        ])
    }

    private func setupMapView() {
        mapView.delegate = self
        mapView.showsScale = true

        addSubview(mapView)
    }

    private func initMarkerManager() {
        markerManager = MarkerManager(mapView: mapView)
    }

    private func initPolylineManager() {
        polylineManager = PolylineManager(mapView: mapView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        mapView.frame = bounds
    }

    // MARK: - 地图命令式方法

    func setInitialRegion(_ region: Region) {
        guard regionToSet == nil else { return }
        regionToSet = region
        mapView.setCenter(
            CLLocationCoordinate2D(latitude: region.center.latitude, longitude: region.center.longitude),
            animated: false
        )
    }

    func setCenter(latitude: Double?, longitude: Double?, promise: Promise) {
        setCenterHandler.begin(
            resolve: { promise.resolve(()) },
            reject: { code, message, error in
                promise.reject(code, message)
            }
        )

        guard let latitude = latitude, let longitude = longitude else {
            setCenterHandler.finishFailure(code: "1", message: "无效的经纬度坐标")
            return
        }
        guard mapView.userTrackingMode == .none else {
            setCenterHandler.finishFailure(code: "1", message: "用户跟踪模式下无法设置中心点")
            return
        }
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        mapView.setCenter(coordinate, animated: true)
        setCenterHandler.finishSuccess(Void())
    }

    func setUserTrackingMode(_ userTrackingMode: Int) {
        if let userTrackingMode = MAUserTrackingMode(rawValue: userTrackingMode) {
            mapView.userTrackingMode = userTrackingMode
            self.userTrackingMode = userTrackingMode
        }
    }

    func setMarkers(_ markers: [Marker]) {
        print("拿到 \(markers.count)个标记")
        markerManager.setMarkers(markers)
    }

    func setPolylines(_ polylines: [Polyline]) {
        polylineManager.setPolylines(polylines)
    }

    func setCustomStyle(_ customStyle: CustomStyle) {
        mapView.customMapStyleEnabled = customStyle.enabled
        let styleOptions = MAMapCustomStyleOptions()
        if let styleData = customStyle.styleData {
            styleOptions.styleData = Data(styleData)
        }
        if let styleExtraData = customStyle.styleExtraData {
            styleOptions.styleExtraData = Data(styleExtraData)
        }
        mapView.setCustomMapStyleOptions(styleOptions)
    }

    func setLanguage(_ language: String) {
        if language == "english" {
            mapView.mapLanguage = NSNumber(value: 1)
        }
        if language == "chinese" {
            mapView.mapLanguage = NSNumber(value: 0)
        }
    }

    func setRegionClusteringOptions(_ options: RegionClusteringOptions?) {
        guard let options = options else { return }

        markerManager.setRegionClusteringOptions(options)
    }
}

// MARK: - MAMapViewDelegate
extension MapView: MAMapViewDelegate {
    func mapViewDidFinishLoadingMap(_ mapView: MAMapView!) {
        if let regionToSet = regionToSet {
            mapView.setRegion(MACoordinateRegion(center: CLLocationCoordinate2D(latitude: regionToSet.center.latitude, longitude: regionToSet.center.longitude), span: MACoordinateSpan(latitudeDelta: regionToSet.span.latitudeDelta, longitudeDelta: regionToSet.span.longitudeDelta)), animated: true)
            self.regionToSet = nil
        }
    }

    // 请求位置权限回调
    func mapViewRequireLocationAuth(_ locationManager: CLLocationManager) {
        if CLLocationManager().authorizationStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        }
    }

    func mapViewRegionChanged(_ mapView: MAMapView!) {
        onRegionChanged([
            "center": [
                "latitude": mapView.region.center.latitude,
                "longitude": mapView.region.center.longitude,
            ],
            "span": [
                "latitudeDelta": mapView.region.span.latitudeDelta,
                "longitudeDelta": mapView.region.span.longitudeDelta,
            ],
        ])
    }

    // 用户位置更新的回调
    func mapView(
        _ mapView: MAMapView!, didUpdate userLocation: MAUserLocation!, updatingLocation: Bool
    ) {
        if updatingLocation && userTrackingMode != .none {
            let coordinate = userLocation.coordinate
            mapView.setCenter(coordinate, animated: true)
        }
    }

    // 渲染标记的回调
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        if let annotation = annotation as? ClusterAnnotation {
            let reuseId = "Cluster_TextAnnotationView"
            var view =
                mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
                as? TextAnnotationView
            if view == nil {
                view = TextAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            } else {
                view?.annotation = annotation
            }
            view?.setText(annotation.title)
            
            return view
        }

        if let annotation = annotation as? MyAnnotation,
           let marker = markerManager.getMarker(id: annotation.id) {
            if marker.style == "custom" {
                let reuseId = "TextAnnotationView"
                var view =
                    mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
                    as? TextAnnotationView
                if view == nil {
                    view = TextAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                } else {
                    view?.annotation = annotation
                }
                view?.setText(marker.title ?? annotation.title)

                if let textStyle = marker.textStyle {
                    view?.textStyle = textStyle
                }
                if let image = marker.image {
                    Task { [weak view] in
                        let uiImage = await ImageLoader.from(image.url)
                        let resized = uiImage?.resized(
                            to: CGSize(width: image.size.width, height: image.size.height))
                        DispatchQueue.main.async {
                            view?.setImage(
                                resized, url: image.url,
                                size: CGSize(width: image.size.width, height: image.size.height))
                        }
                    }
                }
                if let centerOffset = marker.centerOffset {
                    view?.centerOffset = CGPoint(x: centerOffset.x, y: centerOffset.y)
                }
                if let calloutOffset = marker.calloutOffset {
                    view?.calloutOffset = CGPoint(x: calloutOffset.x, y: calloutOffset.y)
                }
                if let textOffset = marker.textOffset {
                    view?.textOffset = CGPoint(x: textOffset.x, y: textOffset.y)
                }
                if let enabled = marker.enabled {
                    view?.isEnabled = enabled
                }
                if let highlighted = marker.highlighted {
                    view?.isHighlighted = highlighted
                }
                if let canShowCallout = marker.canShowCallout {
                    view?.canShowCallout = canShowCallout
                }
                if let draggable = marker.draggable {
                    view?.isDraggable = draggable
                }
                if let canAdjustPosition = marker.canAdjustPosition {
                    view?.canAdjustPositon = canAdjustPosition
                }

                return view
            } else if marker.style == "pin" {
                let reuseId = "PinAnnotationView"
                var view =
                    mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
                    as? MAPinAnnotationView
                if view == nil {
                    view = MAPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                } else {
                    view?.annotation = annotation
                }

                if let pinColor = marker.pinColor {
                    view?.pinColor = MAPinAnnotationColor(rawValue: pinColor) ?? .red
                }
                if let centerOffset = marker.centerOffset {
                    view?.centerOffset = CGPoint(x: centerOffset.x, y: centerOffset.y)
                }
                if let calloutOffset = marker.calloutOffset {
                    view?.calloutOffset = CGPoint(x: calloutOffset.x, y: calloutOffset.y)
                }
                if let enabled = marker.enabled {
                    view?.isEnabled = enabled
                }
                if let highlighted = marker.highlighted {
                    view?.isHighlighted = highlighted
                }
                if let canShowCallout = marker.canShowCallout {
                    view?.canShowCallout = canShowCallout
                }
                if let draggable = marker.draggable {
                    view?.isDraggable = draggable
                }
                if let canAdjustPosition = marker.canAdjustPosition {
                    view?.canAdjustPositon = canAdjustPosition
                }

                return view
            } else if marker.style == "teardrop" {
                let reuseId = "TeardropAnnotationView"
                var view =
                    mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
                    as? TeardropAnnotationView
                if view == nil {
                    view = TeardropAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                } else {
                    view?.annotation = annotation
                }

                if let label = marker.teardropLabel {
                    view?.label = label
                }
                if let seed = marker.teardropRandomFillColorSeed {
                    view?.teardrop.fillColor = UIColor.random(seed: seed)
                } else {
                    view?.teardrop.fillColor = UIColor(hex: "#5981D8")
                }
                if let color = marker.teardropFillColor {
                    view?.teardrop.fillColor = UIColor(hex: color)
                }
                
                return view
            }
        }

        return nil
    }
    
    func mapView(_ mapView: MAMapView!, didAddAnnotationViews views: [Any]!) {
        switchAnnotationsVisibility()
    }

    func mapView(_ mapView: MAMapView!, didAnnotationViewTapped view: MAAnnotationView!) {
        guard
            let view = view,
            let annotation = view.annotation as? MyAnnotation
        else { return }
        
        let point = mapView.convert(annotation.coordinate, toPointTo: mapView)
        
        onTapMarker([
            "id": annotation.id,
            "point": [
                "x": point.x,
                "y": point.y,
            ],
            "coordinate": [
                "latitude": annotation.coordinate.latitude,
                "longitude": annotation.coordinate.longitude
            ]
        ])
    }

    // 渲染覆盖物的回调
    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        if overlay is MAPolyline {
            let renderer: MAPolylineRenderer = MAPolylineRenderer(overlay: overlay)
            if let style = polylineManager.styleForPolyline(overlay as! MAPolyline) {
                if let fillColor = style.fillColor {
                    renderer.fillColor = UIColor(hex: fillColor)
                }
                if let strokeColor = style.strokeColor {
                    renderer.strokeColor = UIColor(hex: strokeColor)
                }
                if let lineWidth = style.lineWidth {
                    renderer.lineWidth = lineWidth
                }
                if let lineJoinType = style.lineJoinType {
                    renderer.lineJoinType = MALineJoinType(rawValue: UInt32(lineJoinType))
                }
                if let lineCapType = style.lineCapType {
                    renderer.lineCapType = MALineCapType(rawValue: UInt32(lineCapType))
                }
                if let miterLimit = style.miterLimit {
                    renderer.miterLimit = CGFloat(miterLimit)
                }
                if let lineDashType = style.lineDashType {
                    renderer.lineDashType = MALineDashType(rawValue: UInt32(lineDashType))
                }
                if let reducePoint = style.reducePoint {
                    renderer.reducePoint = reducePoint
                }
                if let is3DArrowLine = style.is3DArrowLine {
                    renderer.is3DArrowLine = is3DArrowLine
                }
                if let sideColor = style.sideColor {
                    renderer.sideColor = UIColor(hex: sideColor)
                }
                if let userInteractionEnabled = style.userInteractionEnabled {
                    renderer.userInteractionEnabled = userInteractionEnabled
                }
                if let hitTestInset = style.hitTestInset {
                    renderer.hitTestInset = CGFloat(hitTestInset)
                }
                if let showRangeEnabled = style.showRangeEnabled {
                    renderer.showRangeEnabled = showRangeEnabled
                }
                if let pathShowRange = style.pathShowRange {
                    renderer.showRange = MAPathShowRange(
                        begin: Float(pathShowRange.begin), end: Float(pathShowRange.end))
                }
                if let textureImage = style.textureImage {
                    Task {
                        let image = await ImageLoader.from(textureImage)
                        renderer.strokeImage = image
                    }
                }
            }
            return renderer
        }
        return nil
    }

    func mapView(_ mapView: MAMapView!, mapDidZoomByUser wasUserAction: Bool) {
        onZoom(["zoomLevel": mapView.zoomLevel])
        switchAnnotationsVisibility()
    }
    
    func switchAnnotationsVisibility() {
        guard let options = markerManager.regionClusteringOptions, options.enabled ?? false else { return }
        let zoom = mapView.zoomLevel

        // 拿到所有 AnnotationView
        let allViews: [MAAnnotationView] = mapView.annotations.compactMap {
            mapView.view(for: $0 as? MAAnnotation)
        }

        // 聚合点视图
        let clusterViews = allViews
            .filter { ($0.annotation as? ClusterAnnotation) != nil }
        // 普通点视图
        let normalViews = allViews
            .filter { ($0.annotation as? MyAnnotation) != nil }

        // 默认全部隐藏
        clusterViews.forEach { $0.isHidden = true }
        normalViews.forEach { $0.isHidden = true }

        // 按 thresholdZoomLevel 从大到小排序（低层级的 zoom 阈值大）
        let sortedRules = options.rules.sorted { $0.thresholdZoomLevel > $1.thresholdZoomLevel }

        // 找到最适合当前 zoom 的 rule
        var activeRule: RegionClusteringRule? = nil
        for rule in sortedRules {
            if zoom < Double(rule.thresholdZoomLevel) {
                activeRule = rule
            }
        }

        if let rule = activeRule {
            // 显示当前层级的聚合点，普通点隐藏
            for view in clusterViews {
                if let anno = view.annotation as? ClusterAnnotation, anno.by == rule.by {
                    view.isHidden = false
                }
            }
        } else {
            // zoom 足够大，没有匹配的 rule => 显示普通点，聚合点隐藏
            normalViews.forEach { $0.isHidden = false }
            clusterViews.forEach { $0.isHidden = true }
        }
    }
}
