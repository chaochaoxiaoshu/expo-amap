package expo.modules.amap

import android.content.Context
import com.amap.api.services.core.LatLonPoint
import com.amap.api.services.geocoder.GeocodeQuery
import com.amap.api.services.geocoder.GeocodeResult
import com.amap.api.services.geocoder.GeocodeSearch
import com.amap.api.services.geocoder.RegeocodeQuery
import com.amap.api.services.geocoder.RegeocodeResult
import com.amap.api.services.help.Inputtips
import com.amap.api.services.help.InputtipsQuery
import com.amap.api.services.route.BusRouteResult
import com.amap.api.services.route.DriveRouteResult
import com.amap.api.services.route.RideRouteResult
import com.amap.api.services.route.RouteSearch
import com.amap.api.services.route.RouteSearchV2
import com.amap.api.services.route.RouteSearchV2.DriveRouteQuery
import com.amap.api.services.route.WalkRouteResult
import expo.modules.amap.models.SearchDrivingRouteOptions
import expo.modules.amap.models.SearchGeocodeOptions
import expo.modules.amap.models.SearchInputTipsOptions
import expo.modules.amap.models.SearchReGeocodeOptions
import expo.modules.amap.models.SearchRidingRouteOptions
import expo.modules.amap.models.SearchTransitRouteOptions
import expo.modules.amap.models.SearchWalkingRouteOptions
import expo.modules.kotlin.Promise

class SearchManager(private val context: Context) {
    private val routeSearchV2 by lazy { RouteSearchV2(context) }
    private val routeSearch by lazy { RouteSearch(context) }

    fun searchInputTips(options: SearchInputTipsOptions, promise: Promise) {
        val query = InputtipsQuery(options.keywords, options.city)
        query.cityLimit = options.cityLimit ?: false
        val inputTips = Inputtips(context, query)
        inputTips.setInputtipsListener { list, rCode ->
            if (rCode != 1000) {
                promise.reject("E_INPUTTING_FAILED", "\"请求失败，返回码 $rCode\"", null)
                return@setInputtipsListener
            }

            val tips = list.map { tip ->
                mapOf(
                    "uid" to tip.poiID,
                    "name" to tip.name,
                    "address" to tip.address,
                    "adcode" to tip.adcode,
                    "district" to tip.district,
                    "typecode" to tip.typeCode,
                )
            }
            promise.resolve(mapOf("tips" to tips, "count" to tips.size))
        }
        inputTips.requestInputtipsAsyn()
    }

    fun searchGeocode(options: SearchGeocodeOptions, promise: Promise) {
        val query = GeocodeQuery(options.address, options.city)
        val geocoder = GeocodeSearch(context)
        geocoder.setOnGeocodeSearchListener(object : GeocodeSearch.OnGeocodeSearchListener {
            override fun onGeocodeSearched(result: GeocodeResult?, rCode: Int) {
                if (result != null) {
                    val geocodes = result.geocodeAddressList.map { geo ->
                        mapOf(
                            "adcode" to geo.adcode,
                            "building" to geo.building,
                            "city" to geo.city,
                            "citycode" to "",
                            "country" to geo.country,
                            "district" to geo.district,
                            "formattedAddress" to geo.formatAddress,
                            "level" to geo.level,
                            "neighborhood" to geo.neighborhood,
                            "postcode" to geo.postcode,
                            "province" to geo.province,
                            "township" to geo.township
                        )
                    }
                    promise.resolve(mapOf("count" to geocodes.size, "geocodes" to geocodes))
                }
            }

            override fun onRegeocodeSearched(result: RegeocodeResult?, rCode: Int) {
                // 如果不需要反地理编码，可以留空
            }
        })
        geocoder.getFromLocationNameAsyn(query)
    }

    fun searchReGeocode(options: SearchReGeocodeOptions, promise: Promise) {
        val point = options.location?.let { LatLonPoint(it.latitude, it.longitude) }
        val query = RegeocodeQuery(
            point,
            options.radius?.toFloat() ?: 1000f,
            options.mode ?: "default"
        )
        val geocoder = GeocodeSearch(context)

        geocoder.setOnGeocodeSearchListener(object : GeocodeSearch.OnGeocodeSearchListener {
            override fun onGeocodeSearched(result: GeocodeResult?, rCode: Int) {
                // 不处理正向地理编码
            }

            override fun onRegeocodeSearched(result: RegeocodeResult?, rCode: Int) {
                if (result != null) {
                    val regeocode = result.regeocodeAddress  // 使用正确的 getter
                    if (regeocode != null) {
                        val addressComponent: Map<String, String> = mapOf(
                            "adcode" to (regeocode.adCode ?: ""),
                            "building" to (regeocode.building ?: ""),
                            "city" to (regeocode.city ?: ""),
                            "cityCode" to (regeocode.cityCode ?: ""),
                            "country" to (regeocode.country ?: ""),
                            "countryCode" to (regeocode.countryCode ?: ""),
                            "district" to (regeocode.district ?: ""),
                            "neighborhood" to (regeocode.neighborhood ?: ""),
                            "province" to (regeocode.province ?: ""),
                            "towncode" to (regeocode.towncode ?: ""),
                            "township" to (regeocode.township ?: "")
                        )
                        val aois: List<Map<String, String>> = regeocode.aois.map { aoi ->
                            mapOf(
                                "adcode" to (aoi.adCode ?: ""),
                                "name" to (aoi.aoiName ?: ""),
                                "type" to "",
                                "uid" to (aoi.aoiId ?: "")
                            )
                        }
                        val pois: List<Map<String, String>> = regeocode.pois.map { poi ->
                            mapOf(
                                "adcode" to (poi.adCode ?: ""),
                                "address" to (poi.snippet ?: ""),
                                "businessArea" to (poi.businessArea ?: ""),
                                "city" to (poi.cityName ?: ""),
                                "citycode" to (poi.cityCode ?: ""),
                                "direction" to (poi.direction ?: ""),
                                "district" to "",
                                "email" to (poi.email ?: ""),
                                "gridcode" to "",
                                "name" to (poi.title ?: ""),
                                "naviPOIId" to (poi.poiId ?: ""),
                                "parkingType" to (poi.parkingType ?: ""),
                                "pcode" to (poi.provinceCode ?: ""),
                                "postcode" to (poi.postcode ?: ""),
                                "province" to (poi.provinceName ?: ""),
                                "shopID" to (poi.shopID ?: ""),
                                "tel" to (poi.tel ?: ""),
                                "type" to (poi.typeDes ?: ""),
                                "typecode" to (poi.typeCode ?: ""),
                                "uid" to (poi.poiId ?: ""),
                                "website" to (poi.website ?: "")
                            )
                        }
                        val roadinters = arrayOf<Map<String, String>>()
                        val roads: List<Map<String, String>> = regeocode.roads.map { road ->
                            mapOf(
                                "direction" to (road.direction ?: ""),
                                "uid" to (road.id ?: ""),
                                "name" to (road.name ?: ""),
                            )
                        }
                        promise.resolve(
                            mapOf(
                                "formattedAddress" to (regeocode.formatAddress ?: ""),
                                "addressComponent" to addressComponent,
                                "aois" to aois,
                                "pois" to pois,
                                "roadinters" to roadinters,
                                "roads" to roads
                            )
                        )
                    } else {
                        promise.reject("1", "无效的响应数据", null)
                    }
                } else {
                    promise.reject("1", "无效的响应数据", null)
                }
            }
        })

        geocoder.getFromLocationAsyn(query)
    }

    fun searchDrivingRoute(options: SearchDrivingRouteOptions, promise: Promise) {
        val originPoint = LatLonPoint(options.origin.latitude, options.origin.longitude)
        val destPoint = LatLonPoint(options.destination.latitude, options.destination.longitude)
        val fromAndTo = RouteSearchV2.FromAndTo(originPoint, destPoint)
        val drivingStrategy = RouteSearchV2.DrivingStrategy.DEFAULT
        val passedByPoints: List<LatLonPoint>? = null
        val avoidPolygons: List<List<LatLonPoint>>? = null
        val avoidRoad: String? = null
        val query = DriveRouteQuery(fromAndTo, drivingStrategy, passedByPoints, avoidPolygons, avoidRoad)

        routeSearchV2.setRouteSearchListener { result, rCode ->
            if (rCode != 1000) {
                promise.reject("E_INPUTTIPS_FAILED", "\"请求失败，返回码 $rCode\"", null)
                return@setRouteSearchListener
            }

            promise.resolve(mapOf(
                "origin" to mapOf(
                    "latitude" to result.startPos.latitude,
                    "longitude" to result.startPos.longitude
                ),
                "destination" to mapOf(
                    "latitude" to result.targetPos.latitude,
                    "longitude" to result.targetPos.longitude
                ),
                "taxiCost" to result.taxiCost,
                "paths" to result.paths.map { path ->
                    mapOf(
                        "distance" to path.distance,
                        "duration" to path.duration,
                        "stepCount" to path.steps.size,
                        "polyline" to path.polyline.map { point ->
                            mapOf(
                                "latitude" to point.latitude,
                                "longitude" to point.longitude
                            )
                        },
                        "steps" to path.steps.map { step ->
                            mapOf(
                                "stepDistance" to step.stepDistance,
                                "road" to step.road,
                                "routeSearchCityList" to step.routeSearchCityList.map { city ->
                                    mapOf(
                                        "districts" to city.districts.map { district ->
                                            mapOf(
                                                "districtName" to district.districtName,
                                                "" to district.districtAdcode
                                            )
                                        }
                                    )
                                },
                                "navi" to mapOf(
                                    "action" to step.navi.action,
                                    "assistantAction" to step.navi.assistantAction
                                ),
                                "tmCs" to step.tmCs.map { tmCs ->
                                    mapOf(
                                        "distance" to tmCs.distance,
                                        "status" to tmCs.status,
                                        "polyline" to tmCs.polyline.map { point ->
                                            mapOf(
                                                "latitude" to point.latitude,
                                                "longitude" to point.longitude
                                            )
                                        },
                                    )
                                },
                                "costDetail" to mapOf(
                                    "duration" to step.costDetail.duration,
                                    "tolls" to step.costDetail.tolls,
                                    "tollRoad" to step.costDetail.tollRoad,
                                    "tollDistance" to step.costDetail.tollDistance,
                                    "trafficLights" to step.costDetail.trafficLights
                                ),
                                "instruction" to step.instruction,
                                "orientation" to step.orientation,
                                "polyline" to step.polyline.map { point ->
                                    mapOf(
                                        "latitude" to point.latitude,
                                        "longitude" to point.longitude
                                    )
                                }
                            )
                        },
                    )
                },
            ))
        }
        routeSearchV2.calculateDriveRouteAsyn(query)
    }

    fun searchWalkingRoute(options: SearchWalkingRouteOptions, promise: Promise) {
        val originPoint = LatLonPoint(options.origin.latitude, options.origin.longitude)
        val destPoint = LatLonPoint(options.destination.latitude, options.destination.longitude)
        val fromAndTo = RouteSearch.FromAndTo(originPoint, destPoint)

        val query = RouteSearch.WalkRouteQuery(fromAndTo)

        routeSearch.setRouteSearchListener(object : RouteSearch.OnRouteSearchListener {
            override fun onWalkRouteSearched(result: WalkRouteResult?, errorCode: Int) {
                if (errorCode == 1000 && result != null) { // 1000 表示成功
                    promise.resolve(
                        mapOf(
                            "origin" to mapOf(
                                "latitude" to result.startPos.latitude,
                                "longitude" to result.startPos.longitude
                            ),
                            "destination" to mapOf(
                                "latitude" to result.targetPos.latitude,
                                "longitude" to result.targetPos.longitude
                            ),
                            "paths" to result.paths.map { path ->
                                mapOf(
                                    "steps" to path.steps.map { step ->
                                        mapOf(
                                            "road" to step.road,
                                            "polyline" to step.polyline.map { point ->
                                                mapOf(
                                                    "latitude" to point.latitude,
                                                    "longitude" to point.longitude
                                                )
                                            },
                                            "distance" to step.distance,
                                            "duration" to step.duration,
                                            "action" to step.action,
                                            "assistantAction" to step.assistantAction,
                                            "instruction" to step.instruction,
                                            "orientation" to step.orientation
                                        )
                                    },
                                    "distance" to path.distance,
                                    "duration" to path.duration,
                                    "polyline" to path.polyline.map { point ->
                                        mapOf(
                                            "latitude" to point.latitude,
                                            "longitude" to point.longitude
                                        )
                                    }
                                )
                            }
                        )
                    )
                } else {
                    promise.reject("ROUTE_ERROR", "Route search failed with code: $errorCode", null)
                }
            }

            override fun onDriveRouteSearched(result: DriveRouteResult?, errorCode: Int) {}
            override fun onBusRouteSearched(result: BusRouteResult?, errorCode: Int) {}
            override fun onRideRouteSearched(result: RideRouteResult?, errorCode: Int) {}
        })
        routeSearch.calculateWalkRouteAsyn(query)
    }

    fun searchRidingRoute(options: SearchRidingRouteOptions, promise: Promise) {
        val originPoint = LatLonPoint(options.origin.latitude, options.origin.longitude)
        val destPoint = LatLonPoint(options.destination.latitude, options.destination.longitude)
        val fromAndTo = RouteSearch.FromAndTo(originPoint, destPoint)

        val query = RouteSearch.RideRouteQuery(fromAndTo)

        routeSearch.setRouteSearchListener(object : RouteSearch.OnRouteSearchListener {
            override fun onWalkRouteSearched(result: WalkRouteResult?, errorCode: Int) {}
            override fun onDriveRouteSearched(result: DriveRouteResult?, errorCode: Int) {}
            override fun onBusRouteSearched(result: BusRouteResult?, errorCode: Int) {}
            override fun onRideRouteSearched(result: RideRouteResult?, errorCode: Int) {
                if (errorCode == 1000 && result != null) { // 1000 表示成功
                    promise.resolve(
                        mapOf(
                            "origin" to mapOf(
                                "latitude" to result.startPos.latitude,
                                "longitude" to result.startPos.longitude
                            ),
                            "destination" to mapOf(
                                "latitude" to result.targetPos.latitude,
                                "longitude" to result.targetPos.longitude
                            ),
                            "paths" to result.paths.map { path ->
                                mapOf(
                                    "steps" to path.steps.map { step ->
                                        mapOf(
                                            "road" to step.road,
                                            "polyline" to step.polyline.map { point ->
                                                mapOf(
                                                    "latitude" to point.latitude,
                                                    "longitude" to point.longitude
                                                )
                                            },
                                            "distance" to step.distance,
                                            "duration" to step.duration,
                                            "action" to step.action,
                                            "assistantAction" to step.assistantAction,
                                            "instruction" to step.instruction,
                                            "orientation" to step.orientation
                                        )
                                    },
                                    "distance" to path.distance,
                                    "duration" to path.duration,
                                    "polyline" to path.polyline.map { point ->
                                        mapOf(
                                            "latitude" to point.latitude,
                                            "longitude" to point.longitude
                                        )
                                    }
                                )
                            }
                        )
                    )
                } else {
                    promise.reject("ROUTE_ERROR", "Route search failed with code: $errorCode", null)
                }
            }
        })
        routeSearch.calculateRideRouteAsyn(query)
    }

    fun searchTransitRoute(options: SearchTransitRouteOptions, promise: Promise) {
        val originPoint = LatLonPoint(options.origin.latitude, options.origin.longitude)
        val destPoint = LatLonPoint(options.destination.latitude, options.destination.longitude)
        val fromAndTo = RouteSearch.FromAndTo(originPoint, destPoint)
        val mode = RouteSearch.BUS_DEFAULT
        val city = options.city
        val nightFlag = if (options.nightflag) 1 else 0

        val query = RouteSearch.BusRouteQuery(fromAndTo, mode, city, nightFlag)

        routeSearch.setRouteSearchListener(object : RouteSearch.OnRouteSearchListener {
            override fun onWalkRouteSearched(result: WalkRouteResult?, errorCode: Int) {}
            override fun onDriveRouteSearched(result: DriveRouteResult?, errorCode: Int) {}
            override fun onBusRouteSearched(result: BusRouteResult?, errorCode: Int) {
                if (errorCode == 1000 && result != null) { // 1000 表示成功
                    promise.resolve(
                        mapOf(
                            "origin" to mapOf(
                                "latitude" to result.startPos.latitude,
                                "longitude" to result.startPos.longitude
                            ),
                            "destination" to mapOf(
                                "latitude" to result.targetPos.latitude,
                                "longitude" to result.targetPos.longitude
                            ),
                            "paths" to result.paths.map { path ->
                                mapOf(
                                    "steps" to path.steps.map { step ->
                                        mapOf(
                                            "road" to step.busLines.map { busLine ->
                                                mapOf(
                                                    "duration" to busLine.duration,
                                                    "polyline" to busLine.polyline.map { point ->
                                                        mapOf(
                                                            "latitude" to point.latitude,
                                                            "longitude" to point.longitude
                                                        )
                                                    },
                                                    "distance" to busLine.distance,
                                                    "busLineId" to busLine.busLineId,
                                                    "cityCode" to busLine.cityCode,
                                                    "arrivalBusStation" to mapOf(
                                                        "adCode" to busLine.arrivalBusStation.adCode,
                                                        "cityCode" to busLine.arrivalBusStation.cityCode,
                                                        "busStationId" to busLine.arrivalBusStation.busStationId,
                                                        "busStationName" to busLine.arrivalBusStation.busStationName,
                                                        "busLineItems" to busLine.arrivalBusStation.busLineItems,
                                                        "latLonPoint" to mapOf(
                                                            "latitude" to busLine.arrivalBusStation.latLonPoint.latitude,
                                                            "longitude" to busLine.arrivalBusStation.latLonPoint.longitude
                                                        )
                                                    )
                                                )
                                            },
                                            "exit" to mapOf(
                                                "name" to step.exit.name,
                                                "latLonPoint" to mapOf(
                                                    "latitude" to step.exit.latLonPoint.latitude,
                                                    "longitude" to step.exit.latLonPoint.longitude
                                                )
                                            ),
                                            "taxi" to mapOf(
                                                "origin" to mapOf(
                                                    "latitude" to step.taxi.origin.latitude,
                                                    "longitude" to step.taxi.origin.longitude
                                                ),
                                                "distance" to step.taxi.distance,
                                                "duration" to step.taxi.duration,
                                                "destination" to mapOf(
                                                    "latitude" to step.taxi.destination.latitude,
                                                    "longitude" to step.taxi.destination.longitude
                                                )
                                            ),
                                            "walk" to mapOf(
                                                "distance" to step.walk.distance,
                                                "duration" to step.walk.duration,
                                                "polyline" to step.walk.polyline.map { point ->
                                                    mapOf(
                                                        "latitude" to point.latitude,
                                                        "longitude" to point.longitude
                                                    )
                                                },
                                                "origin" to mapOf(
                                                    "latitude" to step.walk.origin.latitude,
                                                    "longitude" to step.walk.origin.longitude
                                                ),
                                                "destination" to mapOf(
                                                    "latitude" to step.walk.destination.latitude,
                                                    "longitude" to step.walk.destination.longitude
                                                )
                                            )
                                        )
                                    },
                                    "distance" to path.distance,
                                    "duration" to path.duration,
                                    "polyline" to path.polyline.map { point ->
                                        mapOf(
                                            "latitude" to point.latitude,
                                            "longitude" to point.longitude
                                        )
                                    }
                                )
                            }
                        )
                    )
                } else {
                    promise.reject("ROUTE_ERROR", "Route search failed with code: $errorCode", null)
                }
            }
            override fun onRideRouteSearched(result: RideRouteResult?, errorCode: Int) {}
        })
        routeSearch.calculateBusRouteAsyn(query)
    }
}