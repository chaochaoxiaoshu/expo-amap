import AMapSearchKit
import ExpoModulesCore
import Foundation

class SearchManager: NSObject {
    private weak var search: AMapSearchAPI?

    private let inputTipsSearchHandler = PromiseDelegateHandler<[String: Any]>()

    private let geocodeSearchHandler = PromiseDelegateHandler<[String: Any]>()
    private let reGeocodeSearchHandler = PromiseDelegateHandler<[String: Any]>()

    private let drivingSearchHandler = PromiseDelegateHandler<[String: Any]>()
    private let walkingSearchHandler = PromiseDelegateHandler<[String: Any]>()
    private let ridingSearchHandler = PromiseDelegateHandler<[String: Any]>()
    private let transitSearchHandler = PromiseDelegateHandler<[String: Any]>()

    init(search: AMapSearchAPI? = nil) {
        self.search = search
    }

    func searchInputTips(_ options: SearchInputTipsOptions, _ promise: Promise) {
        guard let search = search else {
            promise.reject("E_SEARCH_DELEGATE_NOT_FOUND", "搜索委托未初始化")
            return
        }

        inputTipsSearchHandler.begin(
            resolve: { value in promise.resolve(value) },
            reject: { code, message, error in
                promise.reject(code, message)
            }
        )

        let request = AMapInputTipsSearchRequest()
        request.keywords = options.keywords
        request.city = options.city
        request.cityLimit = options.cityLimit ?? false
        request.location = options.location
        request.types = options.types

        search.aMapInputTipsSearch(request)
    }

    func searchGeocode(_ options: SearchGeocodeOptions, _ promise: Promise) {
        guard let search = search else {
            promise.reject("E_SEARCH_DELEGATE_NOT_FOUND", "搜索委托未初始化")
            return
        }

        geocodeSearchHandler.begin(
            resolve: { value in promise.resolve(value) },
            reject: { code, message, error in
                promise.reject(code, message)
            }
        )

        let request = AMapGeocodeSearchRequest()
        request.address = options.address
        request.city = options.city
        request.country = options.country

        search.aMapGeocodeSearch(request)
    }

    func searchReGeocode(_ options: SearchReGeocodeOptions, _ promise: Promise) {
        guard let search = search else {
            promise.reject("E_SEARCH_DELEGATE_NOT_FOUND", "搜索委托未初始化")
            return
        }

        reGeocodeSearchHandler.begin(
            resolve: { value in promise.resolve(value) },
            reject: { code, message, error in
                promise.reject(code, message)
            }
        )

        let request = AMapReGeocodeSearchRequest()
        if let location = options.location {
            request.location = AMapGeoPoint.location(
                withLatitude: location.latitude, longitude: location.longitude)
        }
        request.mode = options.mode
        request.poitype = options.poitype
        request.radius = options.radius ?? 1000
        request.requireExtension = options.requireExtension ?? false

        search.aMapReGoecodeSearch(request)
    }

    func searchDrivingRoute(_ options: SearchDrivingRouteOptions, _ promise: Promise) {
        guard let search = search else {
            promise.reject("E_SEARCH_DELEGATE_NOT_FOUND", "搜索委托未初始化")
            return
        }

        drivingSearchHandler.begin(
            resolve: { value in promise.resolve(value) },
            reject: { code, message, error in
                promise.reject(code, message)
            }
        )

        var showFieldType: AMapDrivingRouteShowFieldType? = nil
        switch options.showFieldType {
        case .none:
            showFieldType = AMapDrivingRouteShowFieldType.none
        case .cost:
            showFieldType = .cost
        case .tmcs:
            showFieldType = .tmcs
        case .navi:
            showFieldType = .navi
        case .cities:
            showFieldType = .cities
        case .polyline:
            showFieldType = .polyline
        case .newEnergy:
            showFieldType = .newEnergy
        case .all:
            showFieldType = .all
        }

        let request = AMapDrivingCalRouteSearchRequest()
        request.origin = AMapGeoPoint.location(
            withLatitude: options.origin.latitude, longitude: options.origin.longitude)
        request.destination = AMapGeoPoint.location(
            withLatitude: options.destination.latitude, longitude: options.destination.longitude)
        request.showFieldType = showFieldType ?? .none

        search.aMapDrivingV2RouteSearch(request)
    }

    func searchWalkingRoute(_ options: SearchWalkingRouteOptions, _ promise: Promise) {
        guard let search = search else {
            promise.reject("E_SEARCH_DELEGATE_NOT_FOUND", "搜索委托未初始化")
            return
        }

        walkingSearchHandler.begin(
            resolve: { value in promise.resolve(value) },
            reject: { code, message, error in
                promise.reject(code, message)
            }
        )

        var showFieldType: AMapWalkingRouteShowFieldType? = nil
        switch options.showFieldType {
        case .none:
            showFieldType = AMapWalkingRouteShowFieldType.none
        case .cost:
            showFieldType = .cost
        case .navi:
            showFieldType = .navi
        case .polyline:
            showFieldType = .polyline
        case .all:
            showFieldType = .all
        }

        let request = AMapWalkingRouteSearchRequest()
        request.origin = AMapGeoPoint.location(
            withLatitude: options.origin.latitude, longitude: options.origin.longitude)
        request.destination = AMapGeoPoint.location(
            withLatitude: options.destination.latitude, longitude: options.destination.longitude)
        request.showFieldsType = showFieldType ?? .none

        search.aMapWalkingRouteSearch(request)
    }

    func searchRidingRoute(_ options: SearchRidingRouteOptions, _ promise: Promise) {
        guard let search = search else {
            promise.reject("E_SEARCH_DELEGATE_NOT_FOUND", "搜索委托未初始化")
            return
        }

        ridingSearchHandler.begin(
            resolve: { value in promise.resolve(value) },
            reject: { code, message, error in
                promise.reject(code, message)
            }
        )

        var showFieldType: AMapRidingRouteShowFieldsType? = nil
        switch options.showFieldType {
        case .none:
            showFieldType = AMapRidingRouteShowFieldsType.none
        case .cost:
            showFieldType = .cost
        case .navi:
            showFieldType = .navi
        case .polyline:
            showFieldType = .polyline
        case .all:
            showFieldType = .all
        }

        let request = AMapRidingRouteSearchRequest()
        request.origin = AMapGeoPoint.location(
            withLatitude: options.origin.latitude, longitude: options.origin.longitude)
        request.destination = AMapGeoPoint.location(
            withLatitude: options.destination.latitude, longitude: options.destination.longitude)
        request.showFieldsType = showFieldType ?? .none
        request.alternativeRoute = options.alternativeRoute

        search.aMapRidingRouteSearch(request)
    }

    func searchTransitRoute(_ options: SearchTransitRouteOptions, _ promise: Promise) {
        guard let search = search else {
            promise.reject("E_SEARCH_DELEGATE_NOT_FOUND", "搜索委托未初始化")
            return
        }

        transitSearchHandler.begin(
            resolve: { value in promise.resolve(value) },
            reject: { code, message, error in
                promise.reject(code, message)
            }
        )

        var showFieldType: AMapTransitRouteShowFieldsType? = nil
        switch options.showFieldType {
        case .none:
            showFieldType = AMapTransitRouteShowFieldsType.none
        case .cost:
            showFieldType = .cost
        case .navi:
            showFieldType = .navi
        case .polyline:
            showFieldType = .polyline
        case .all:
            showFieldType = .all
        }

        let request = AMapTransitRouteSearchRequest()
        request.origin = AMapGeoPoint.location(
            withLatitude: options.origin.latitude, longitude: options.origin.longitude)
        request.destination = AMapGeoPoint.location(
            withLatitude: options.destination.latitude, longitude: options.destination.longitude)
        request.strategy = options.strategy
        request.city = options.city
        request.destinationCity = options.destinationCity
        request.nightflag = options.nightflag
        request.originPOI = options.originPOI
        request.destinationPOI = options.destinationPOI
        request.adcode = options.adcode
        request.destinationAdcode = options.destinationAdcode
        request.alternativeRoute = options.alternativeRoute ?? 5
        request.multiExport = options.multiExport ?? false
        request.maxTrans = options.maxTrans ?? 4
        request.date = options.date
        request.time = options.time
        request.showFieldsType = showFieldType ?? .none

        search.aMapTransitRouteSearch(request)
    }
}

extension SearchManager: AMapSearchDelegate {

    func onInputTipsSearchDone(
        _ request: AMapInputTipsSearchRequest!, response: AMapInputTipsSearchResponse!
    ) {
        guard let response = response else {
            inputTipsSearchHandler.finishFailure(code: "1", message: "无效的响应数据")
            return
        }

        inputTipsSearchHandler.finishSuccess([
            "tips": response.tips.compactMap({ tip in
                [
                    "uid": tip.uid ?? "",
                    "name": tip.name ?? "",
                    "address": tip.address ?? "",
                    "adcode": tip.adcode ?? "",
                    "district": tip.district ?? "",
                    "typecode": tip.typecode ?? "",
                    "location": [
                        "latitude": tip.location.latitude,
                        "longitude": tip.location.longitude
                    ]
                ]
            }),
            "count": response.count,
        ])
    }

    func onGeocodeSearchDone(
        _ request: AMapGeocodeSearchRequest!, response: AMapGeocodeSearchResponse!
    ) {
        guard let response = response else {
            geocodeSearchHandler.finishFailure(code: "1", message: "无效的响应数据")
            return
        }

        geocodeSearchHandler.finishSuccess([
            "count": response.count,
            "geocodes": response.geocodes.compactMap({ geocode in
                [
                    "adcode": geocode.adcode,
                    "building": geocode.building,
                    "city": geocode.city,
                    "citycode": geocode.citycode,
                    "country": geocode.country,
                    "district": geocode.district,
                    "formattedAddress": geocode.formattedAddress,
                    "level": geocode.level,
                    "neighborhood": geocode.neighborhood,
                    "postcode": geocode.postcode,
                    "province": geocode.province,
                    "township": geocode.township,
                ]
            }),
        ])
    }

    func onReGeocodeSearchDone(
        _ request: AMapReGeocodeSearchRequest!, response: AMapReGeocodeSearchResponse!
    ) {
        guard let response = response else {
            reGeocodeSearchHandler.finishFailure(code: "1", message: "无效的响应数据")
            return
        }

        reGeocodeSearchHandler.finishSuccess([
            "formattedAddress": response.regeocode.formattedAddress ?? "",
            "addressComponent": [
                "adcode": response.regeocode.addressComponent.adcode,
                "building": response.regeocode.addressComponent.building,
                "city": response.regeocode.addressComponent.city,
                "citycode": response.regeocode.addressComponent.citycode,
                "country": response.regeocode.addressComponent.country,
                "countryCode": response.regeocode.addressComponent.countryCode,
                "district": response.regeocode.addressComponent.district,
                "neighborhood": response.regeocode.addressComponent.neighborhood,
                "province": response.regeocode.addressComponent.province,
                "towncode": response.regeocode.addressComponent.towncode,
                "township": response.regeocode.addressComponent.township,
            ],
            "aois": response.regeocode.aois?.compactMap({ aoi in
                [
                    "adcode": aoi.adcode,
                    "name": aoi.name,
                    "type": aoi.type,
                    "uid": aoi.uid,
                ]
            }) ?? [],
            "pois": response.regeocode.pois?.compactMap({ poi in
                [
                    "adcode": poi.adcode,
                    "address": poi.address,
                    "businessArea": poi.businessArea,
                    "city": poi.city,
                    "citycode": poi.citycode,
                    "direction": poi.direction,
                    "district": poi.district,
                    "email": poi.email,
                    "gridcode": poi.gridcode,
                    "name": poi.name,
                    "naviPOIId": poi.naviPOIId,
                    "parkingType": poi.parkingType,
                    "pcode": poi.pcode,
                    "postcode": poi.postcode,
                    "province": poi.province,
                    "shopID": poi.shopID,
                    "tel": poi.tel,
                    "type": poi.type,
                    "typecode": poi.typecode,
                    "uid": poi.uid,
                    "website": poi.website,
                ]
            }) ?? [],
            "roadinters": response.regeocode.roadinters?.compactMap({ roadInter in
                [
                    "direction": roadInter.direction,
                    "firstId": roadInter.firstId,
                    "firstName": roadInter.firstName,
                    "secondId": roadInter.secondId,
                    "secondName": roadInter.secondName,
                ]
            }) ?? [],
            "roads": response.regeocode.roads?.compactMap({ road in
                [
                    "direction": road.direction,
                    "name": road.name,
                    "uid": road.uid,
                ]
            }) ?? [],
        ])
    }

    // 路线搜索完成的回调
    func onRouteSearchDone(
        _ request: AMapRouteSearchBaseRequest!, response: AMapRouteSearchResponse!
    ) {
        guard let response = response, let route = response.route else {
            if request is AMapDrivingCalRouteSearchRequest {
                drivingSearchHandler.finishFailure(code: "1", message: "无效的响应数据")
            } else if request is AMapWalkingRouteSearchRequest {
                walkingSearchHandler.finishFailure(code: "1", message: "无效的响应数据")
            } else if request is AMapRidingRouteSearchRequest {
                ridingSearchHandler.finishFailure(code: "1", message: "无效的响应数据")
            } else if request is AMapTransitRouteSearchRequest {
                transitSearchHandler.finishFailure(code: "1", message: "无效的响应数据")
            }
            return
        }

        if request is AMapDrivingCalRouteSearchRequest {
            drivingSearchHandler.finishSuccess([
                "success": true,
                "count": response.count,
                "route": Utils.serializeRouteResponse(route),
            ])
        } else if request is AMapWalkingRouteSearchRequest {
            walkingSearchHandler.finishSuccess([
                "success": true,
                "count": response.count,
                "route": Utils.serializeRouteResponse(route),
            ])
        } else if request is AMapRidingRouteSearchRequest {
            ridingSearchHandler.finishSuccess([
                "success": true,
                "count": response.count,
                "route": Utils.serializeRouteResponse(route),
            ])
        } else if request is AMapTransitRouteSearchRequest {
            transitSearchHandler.finishSuccess([
                "success": true,
                "count": response.count,
                "route": Utils.serializeRouteResponse(route),
            ])
        }
    }

    // 路线搜索失败的回调
    func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
        if request is AMapDrivingCalRouteSearchRequest {
            drivingSearchHandler.finishFailure(
                code: "1", message: "路线规划失败: \(error?.localizedDescription ?? "Unknown error")")
        } else if request is AMapWalkingRouteSearchRequest {
            walkingSearchHandler.finishFailure(
                code: "1", message: "路线规划失败: \(error?.localizedDescription ?? "Unknown error")")
        } else if request is AMapRidingRouteSearchRequest {
            ridingSearchHandler.finishFailure(
                code: "1", message: "路线规划失败: \(error?.localizedDescription ?? "Unknown error")")
        } else if request is AMapTransitRouteSearchRequest {
            transitSearchHandler.finishFailure(
                code: "1", message: "路线规划失败: \(error?.localizedDescription ?? "Unknown error")")
        }
    }
}
