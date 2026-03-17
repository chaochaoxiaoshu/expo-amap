import AMapFoundationKit
import AMapLocationKit
import AMapSearchKit
import ExpoModulesCore
import MAMapKit

public class ExpoAmapModule: Module {
    private var locationManager: AMapLocationManager?
    private var locationDelegate: LocationManagerDelegate?

    private var search: AMapSearchAPI?
    private var searchManager: SearchManager?

    public func definition() -> ModuleDefinition {
        Name("ExpoAmap")

        OnCreate {
            let apiKey = Bundle.main.object(forInfoDictionaryKey: "AMAP_API_KEY") as? String
            AMapServices.shared().apiKey = apiKey
            AMapServices.shared().enableHTTPS = true

            MAMapView.updatePrivacyAgree(AMapPrivacyAgreeStatus.didAgree)
            MAMapView.updatePrivacyShow(
                AMapPrivacyShowStatus.didShow, privacyInfo: AMapPrivacyInfoStatus.didContain)
    
            locationManager = AMapLocationManager()
            locationDelegate = LocationManagerDelegate()
            locationManager?.delegate = locationDelegate
            locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager?.locationTimeout = 10
            locationManager?.reGeocodeTimeout = 5
            locationManager?.locatingWithReGeocode = true
            locationManager?.pausesLocationUpdatesAutomatically = false
            locationManager?.distanceFilter = kCLDistanceFilterNone

            search = AMapSearchAPI()
            searchManager = SearchManager(search: search)
            search?.delegate = searchManager
        }

        AsyncFunction("requestLocation") { (promise: Promise) -> Void in
            guard let locationManager = self.locationManager else {
                promise.reject("E_LOCATION_MANAGER_NOT_FOUND", "定位管理器未初始化")
                return
            }

            locationManager.requestLocation(withReGeocode: true) { location, regeocode, error in
                if let error = error {
                    let nsError = error as NSError
                    let errorCode = "LOCATION_ERROR_\(nsError.code)"
                    let errorMessage = "定位失败: \(error.localizedDescription)"
                    promise.reject(errorCode, errorMessage)
                    return
                }

                guard let location = location else {
                    promise.reject("LOCATION_ERROR", "定位失败，location 为空")
                    return
                }

                // 高德 AMapLocationManager 返回的坐标已经是 GCJ-02，无需手动转换
                var result: [String: Any] = [:]
                result["latitude"] = location.coordinate.latitude
                result["longitude"] = location.coordinate.longitude
                result["accuracy"] = location.horizontalAccuracy

                if let regeocode = regeocode {
                    var regeocodeDict: [String: String] = [:]
                    regeocodeDict["formattedAddress"] = regeocode.formattedAddress ?? ""
                    regeocodeDict["country"] = regeocode.country ?? ""
                    regeocodeDict["province"] = regeocode.province ?? ""
                    regeocodeDict["city"] = regeocode.city ?? ""
                    regeocodeDict["district"] = regeocode.district ?? ""
                    regeocodeDict["citycode"] = regeocode.citycode ?? ""
                    regeocodeDict["adcode"] = regeocode.adcode ?? ""
                    regeocodeDict["street"] = regeocode.street ?? ""
                    regeocodeDict["number"] = regeocode.number ?? ""
                    regeocodeDict["poiName"] = regeocode.poiName ?? ""
                    regeocodeDict["aoiName"] = regeocode.aoiName ?? ""
                    result["regeocode"] = regeocodeDict
                }

                promise.resolve(result)
            }
        }

        AsyncFunction("searchInputTips") {
            (options: SearchInputTipsOptions, promise: Promise) -> Void in
            searchManager?.searchInputTips(options, promise)
        }

        AsyncFunction("searchGeocode") {
            (options: SearchGeocodeOptions, promise: Promise) -> Void in
            searchManager?.searchGeocode(options, promise)
        }

        AsyncFunction("searchReGeocode") {
            (options: SearchReGeocodeOptions, promise: Promise) -> Void in
            searchManager?.searchReGeocode(options, promise)
        }

        AsyncFunction("searchDrivingRoute") {
            (options: SearchDrivingRouteOptions, promise: Promise) -> Void in
            searchManager?.searchDrivingRoute(options, promise)
        }

        AsyncFunction("searchWalkingRoute") {
            (options: SearchWalkingRouteOptions, promise: Promise) -> Void in
            searchManager?.searchWalkingRoute(options, promise)
        }

        AsyncFunction("searchRidingRoute") {
            (options: SearchRidingRouteOptions, promise: Promise) -> Void in
            searchManager?.searchRidingRoute(options, promise)
        }

        AsyncFunction("searchTransitRoute") {
            (options: SearchTransitRouteOptions, promise: Promise) -> Void in
            searchManager?.searchTransitRoute(options, promise)
        }

        View(MapView.self) {
            Events("onLoad", "onZoom", "onRegionChanged", "onTapMarker", "onTapPolyline")

            Prop("initialRegion") { (view, region: Region) in
                view.setInitialRegion(region)
            }

            Prop("limitedRegion") { (view, region: Region) in
                view.mapView.limitRegion = MACoordinateRegion(
                    center: CLLocationCoordinate2D(
                        latitude: region.center.latitude, longitude: region.center.longitude),
                    span: MACoordinateSpan(
                        latitudeDelta: region.span.latitudeDelta,
                        longitudeDelta: region.span.longitudeDelta))
            }

            Prop("mapType") { (view, mapType: Int) in
                view.mapView.mapType = MAMapType(rawValue: mapType) ?? .standard
            }

            Prop("showCompass") { (view, showCompass: Bool) in
                view.mapView.showsCompass = showCompass
            }

            Prop("showUserLocation") { (view, showUserLocation: Bool) in
                view.mapView.showsUserLocation = showUserLocation
            }

            Prop("userTrackingMode") { (view, userTrackingMode: Int) in
                view.setUserTrackingMode(userTrackingMode)
            }

            Prop("markers") { (view, markers: [Marker]) in
                view.setMarkers(markers)
            }

            Prop("polylines") { (view, segments: [Polyline]) in
                view.setPolylines(segments)
            }

            Prop("customStyle") { (view, customStyle: CustomStyle) in
                view.setCustomStyle(customStyle)
            }

            Prop("language") { (view, language: String) in
                view.setLanguage(language)
            }

            Prop("minZoomLevel") { (view, minZoomLevel: Double) in
                view.mapView.minZoomLevel = minZoomLevel
            }

            Prop("maxZoomLevel") { (view, maxZoomLevel: Double) in
                view.mapView.maxZoomLevel = maxZoomLevel
            }

            Prop("regionClusteringOptions") { (view, options: RegionClusteringOptions) in
                view.setRegionClusteringOptions(options)
            }

            AsyncFunction("setCenter") {
                (view: MapView, centerCoordinate: [String: Double], promise: Promise) in
                view.setCenter(
                    latitude: centerCoordinate["latitude"],
                    longitude: centerCoordinate["longitude"],
                    promise: promise)
            }

            AsyncFunction("setZoomLevel") { (view: MapView, zoomLevel: Int) in
                view.mapView.setZoomLevel(CGFloat(zoomLevel), animated: true)
            }
        }
    }
}
