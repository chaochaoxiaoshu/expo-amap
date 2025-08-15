import AMapFoundationKit
import AMapLocationKit
import AMapSearchKit
import ExpoModulesCore
import MAMapKit

class MapView: ExpoView {
    let mapView = MAMapView()

    // 是否已经设置了初始 region
    var regionSetted: Bool = false

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

    func setRegion(_ region: Region, animated: Bool?) {
        mapView.setRegion(
            MACoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: region.center.latitude, longitude: region.center.longitude),
                span: MACoordinateSpan(
                    latitudeDelta: region.span.latitudeDelta,
                    longitudeDelta: region.span.longitudeDelta)),
            animated: animated ?? false)
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

        self.markerManager.setRegionClusteringOptions(options)
    }
}

// MARK: - MAMapViewDelegate
extension MapView: MAMapViewDelegate {
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

        if let annotation = annotation as? SSAnnotation,
            let marker = markerManager.getMarker(id: annotation.id)
        {
            if let image = marker.image {
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
                if let zIndex = marker.zIndex {
                    view?.zIndex = zIndex
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
            } else {
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
                if let zIndex = marker.zIndex {
                    view?.zIndex = zIndex
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
            }
        }
        return nil
    }

    func mapView(_ mapView: MAMapView!, didAnnotationViewTapped view: MAAnnotationView!) {
        guard
            let view = view as? TextAnnotationView,
            let annotation = view.annotation as? SSAnnotation,
            let marker = markerManager.getMarker(id: annotation.id)
        else { return }

        let point = mapView.convert(annotation.coordinate, toPointTo: mapView)

        onTapMarker([
            "id": marker.id,
            "point": [
                "x": point.x,
                "y": point.y,
            ],
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

        if let options = markerManager.regionClusteringOptions, options.enabled == true {

        }
    }
}
