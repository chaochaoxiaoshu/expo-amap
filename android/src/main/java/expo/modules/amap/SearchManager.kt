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

            val tips =
                    list.map { tip ->
                        mapOf(
                                "uid" to (tip?.poiID ?: ""),
                                "name" to (tip?.name ?: ""),
                                "address" to (tip?.address ?: ""),
                                "adcode" to (tip?.adcode ?: ""),
                                "district" to (tip?.district ?: ""),
                                "typecode" to (tip?.typeCode ?: ""),
                                "location" to
                                        mapOf(
                                                "latitude" to (tip?.point?.latitude ?: 0.0),
                                                "longitude" to (tip?.point?.longitude ?: 0.0)
                                        )
                        )
                    }
            promise.resolve(mapOf("count" to list.size, "tips" to tips))
        }
        inputTips.requestInputtipsAsyn()
    }

    fun searchGeocode(options: SearchGeocodeOptions, promise: Promise) {
        val query = GeocodeQuery(options.address, options.city)
        val geocoder = GeocodeSearch(context)
        geocoder.setOnGeocodeSearchListener(
                object : GeocodeSearch.OnGeocodeSearchListener {
                    override fun onGeocodeSearched(result: GeocodeResult?, rCode: Int) {
                        if (result != null) {
                            val geocodes =
                                    result.geocodeAddressList.map { geo ->
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
                }
        )
        geocoder.getFromLocationNameAsyn(query)
    }

    fun searchReGeocode(options: SearchReGeocodeOptions, promise: Promise) {
        val point = options.location?.let { LatLonPoint(it.latitude, it.longitude) }
        val query =
                RegeocodeQuery(point, options.radius?.toFloat() ?: 1000f, options.mode ?: "default")
        val geocoder = GeocodeSearch(context)

        geocoder.setOnGeocodeSearchListener(
                object : GeocodeSearch.OnGeocodeSearchListener {
                    override fun onGeocodeSearched(result: GeocodeResult?, rCode: Int) {
                        // 不处理正向地理编码
                    }

                    override fun onRegeocodeSearched(result: RegeocodeResult?, rCode: Int) {
                        if (result != null) {
                            val regeocode = result.regeocodeAddress // 使用正确的 getter
                            if (regeocode != null) {
                                val addressComponent: Map<String, String> =
                                        mapOf(
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
                                val aois: List<Map<String, String>> =
                                        regeocode.aois.map { aoi ->
                                            mapOf(
                                                    "adcode" to (aoi.adCode ?: ""),
                                                    "name" to (aoi.aoiName ?: ""),
                                                    "type" to "",
                                                    "uid" to (aoi.aoiId ?: "")
                                            )
                                        }
                                val pois: List<Map<String, String>> =
                                        regeocode.pois.map { poi ->
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
                                val roads: List<Map<String, String>> =
                                        regeocode.roads.map { road ->
                                            mapOf(
                                                    "direction" to (road.direction ?: ""),
                                                    "uid" to (road.id ?: ""),
                                                    "name" to (road.name ?: ""),
                                            )
                                        }
                                promise.resolve(
                                        mapOf(
                                                "formattedAddress" to
                                                        (regeocode.formatAddress ?: ""),
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
                }
        )

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
        val query =
                DriveRouteQuery(
                        fromAndTo,
                        drivingStrategy,
                        passedByPoints,
                        avoidPolygons,
                        avoidRoad
                )

        // 指定需要返回的字段，确保包含坐标折线等
        try {
            var showFields = 0
            when (options.showFieldType.value) {
                "none" -> showFields = 0
                "polyline" -> showFields = RouteSearchV2.ShowFields.POLINE
                "cost" -> showFields = RouteSearchV2.ShowFields.COST
                "tmcs" -> showFields = RouteSearchV2.ShowFields.TMCS
                "navi" -> showFields = RouteSearchV2.ShowFields.NAVI
                "cities" -> showFields = RouteSearchV2.ShowFields.CITIES
                "all" ->
                        showFields =
                                RouteSearchV2.ShowFields.POLINE or
                                        RouteSearchV2.ShowFields.CITIES or
                                        RouteSearchV2.ShowFields.COST or
                                        RouteSearchV2.ShowFields.NAVI or
                                        RouteSearchV2.ShowFields.TMCS
                else -> {
                    // 默认至少返回折线
                    showFields = RouteSearchV2.ShowFields.POLINE
                }
            }
            // 折线通常与其它信息同时需要；若仅选 cost/navi 等，仍追加折线
            if (showFields != 0 && (showFields and RouteSearchV2.ShowFields.POLINE) == 0) {
                showFields = showFields or RouteSearchV2.ShowFields.POLINE
            }
            query.setShowFields(showFields)
        } catch (_: Exception) {}

        routeSearchV2.setRouteSearchListener { result, rCode ->
            if (rCode != 1000) {
                promise.reject("E_INPUTTIPS_FAILED", "\"请求失败，返回码 $rCode\"", null)
                return@setRouteSearchListener
            }

            promise.resolve(
                    mapOf(
                            "success" to true,
                            "count" to result.paths.size,
                            "route" to
                                    mapOf(
                                            "origin" to
                                                    mapOf(
                                                            "latitude" to
                                                                    (result.startPos?.latitude
                                                                            ?: 0.0),
                                                            "longitude" to
                                                                    (result.startPos?.longitude
                                                                            ?: 0.0)
                                                    ),
                                            "destination" to
                                                    mapOf(
                                                            "latitude" to
                                                                    (result.targetPos?.latitude
                                                                            ?: 0.0),
                                                            "longitude" to
                                                                    (result.targetPos?.longitude
                                                                            ?: 0.0)
                                                    ),
                                            "taxiCost" to (result.taxiCost ?: 0.0),
                                            "paths" to
                                                    (result.paths ?: emptyList()).map { path ->
                                                        mapOf(
                                                                "distance" to (path?.distance ?: 0),
                                                                "duration" to (path?.duration ?: 0),
                                                                "stepCount" to
                                                                        (path?.steps?.size ?: 0),
                                                                "polyline" to
                                                                        run {
                                                                            val direct =
                                                                                    path?.polyline
                                                                                            ?: emptyList()
                                                                            val merged =
                                                                                    if (direct.isNotEmpty()
                                                                                    )
                                                                                            direct
                                                                                    else
                                                                                            (path?.steps
                                                                                                            ?: emptyList())
                                                                                                    .flatMap {
                                                                                                        it?.polyline
                                                                                                                ?: emptyList()
                                                                                                    }
                                                                            merged.map { point ->
                                                                                mapOf(
                                                                                        "latitude" to
                                                                                                (point?.latitude
                                                                                                        ?: 0.0),
                                                                                        "longitude" to
                                                                                                (point?.longitude
                                                                                                        ?: 0.0)
                                                                                )
                                                                            }
                                                                        },
                                                                "steps" to
                                                                        (path?.steps ?: emptyList())
                                                                                .map { step ->
                                                                                    mapOf(
                                                                                            "stepDistance" to
                                                                                                    (step?.stepDistance
                                                                                                            ?: 0),
                                                                                            "road" to
                                                                                                    (step?.road
                                                                                                            ?: ""),
                                                                                            "routeSearchCityList" to
                                                                                                    (step?.routeSearchCityList
                                                                                                                    ?: emptyList())
                                                                                                            .map {
                                                                                                                    city
                                                                                                                ->
                                                                                                                mapOf(
                                                                                                                        "districts" to
                                                                                                                                (city?.districts
                                                                                                                                                ?: emptyList())
                                                                                                                                        .map {
                                                                                                                                                district
                                                                                                                                            ->
                                                                                                                                            mapOf(
                                                                                                                                                    "districtName" to
                                                                                                                                                            (district?.districtName
                                                                                                                                                                    ?: ""),
                                                                                                                                                    "districtAdcode" to
                                                                                                                                                            (district?.districtAdcode
                                                                                                                                                                    ?: "")
                                                                                                                                            )
                                                                                                                                        }
                                                                                                                )
                                                                                                            },
                                                                                            "navi" to
                                                                                                    mapOf(
                                                                                                            "action" to
                                                                                                                    (step?.navi
                                                                                                                            ?.action
                                                                                                                            ?: ""),
                                                                                                            "assistantAction" to
                                                                                                                    (step?.navi
                                                                                                                            ?.assistantAction
                                                                                                                            ?: "")
                                                                                                    ),
                                                                                            "tmCs" to
                                                                                                    (step?.tmCs
                                                                                                                    ?: emptyList())
                                                                                                            .map {
                                                                                                                    tmCs
                                                                                                                ->
                                                                                                                mapOf(
                                                                                                                        "distance" to
                                                                                                                                (tmCs?.distance
                                                                                                                                        ?: 0),
                                                                                                                        "status" to
                                                                                                                                (tmCs?.status
                                                                                                                                        ?: ""),
                                                                                                                        "polyline" to
                                                                                                                                (tmCs?.polyline
                                                                                                                                                ?: emptyList())
                                                                                                                                        .map {
                                                                                                                                                point
                                                                                                                                            ->
                                                                                                                                            mapOf(
                                                                                                                                                    "latitude" to
                                                                                                                                                            (point?.latitude
                                                                                                                                                                    ?: 0.0),
                                                                                                                                                    "longitude" to
                                                                                                                                                            (point?.longitude
                                                                                                                                                                    ?: 0.0)
                                                                                                                                            )
                                                                                                                                        }
                                                                                                                )
                                                                                                            },
                                                                                            "costDetail" to
                                                                                                    mapOf(
                                                                                                            "duration" to
                                                                                                                    (step?.costDetail
                                                                                                                            ?.duration
                                                                                                                            ?: 0),
                                                                                                            "tolls" to
                                                                                                                    (step?.costDetail
                                                                                                                            ?.tolls
                                                                                                                            ?: 0),
                                                                                                            "tollRoad" to
                                                                                                                    (step?.costDetail
                                                                                                                            ?.tollRoad
                                                                                                                            ?: 0),
                                                                                                            "tollDistance" to
                                                                                                                    (step?.costDetail
                                                                                                                            ?.tollDistance
                                                                                                                            ?: 0),
                                                                                                            "trafficLights" to
                                                                                                                    (step?.costDetail
                                                                                                                            ?.trafficLights
                                                                                                                            ?: 0)
                                                                                                    ),
                                                                                            "instruction" to
                                                                                                    (step?.instruction
                                                                                                            ?: ""),
                                                                                            "orientation" to
                                                                                                    (step?.orientation
                                                                                                            ?: 0),
                                                                                            "polyline" to
                                                                                                    (step?.polyline
                                                                                                                    ?: emptyList())
                                                                                                            .map {
                                                                                                                    point
                                                                                                                ->
                                                                                                                mapOf(
                                                                                                                        "latitude" to
                                                                                                                                (point?.latitude
                                                                                                                                        ?: 0.0),
                                                                                                                        "longitude" to
                                                                                                                                (point?.longitude
                                                                                                                                        ?: 0.0)
                                                                                                                )
                                                                                                            }
                                                                                    )
                                                                                }
                                                        )
                                                    }
                                    )
                    )
            )
        }
        routeSearchV2.calculateDriveRouteAsyn(query)
    }

    fun searchWalkingRoute(options: SearchWalkingRouteOptions, promise: Promise) {
        val originPoint = LatLonPoint(options.origin.latitude, options.origin.longitude)
        val destPoint = LatLonPoint(options.destination.latitude, options.destination.longitude)
        val fromAndTo = RouteSearch.FromAndTo(originPoint, destPoint)

        val query = RouteSearch.WalkRouteQuery(fromAndTo)

        routeSearch.setRouteSearchListener(
                object : RouteSearch.OnRouteSearchListener {
                    override fun onWalkRouteSearched(result: WalkRouteResult?, errorCode: Int) {
                        if (errorCode == 1000 && result != null) { // 1000 表示成功
                            promise.resolve(
                                    mapOf(
                                            "success" to true,
                                            "count" to result.paths.size,
                                            "route" to
                                                    mapOf(
                                                            "origin" to
                                                                    mapOf(
                                                                            "latitude" to
                                                                                    (result.startPos
                                                                                            ?.latitude
                                                                                            ?: 0.0),
                                                                            "longitude" to
                                                                                    (result.startPos
                                                                                            ?.longitude
                                                                                            ?: 0.0)
                                                                    ),
                                                            "destination" to
                                                                    mapOf(
                                                                            "latitude" to
                                                                                    (result.targetPos
                                                                                            ?.latitude
                                                                                            ?: 0.0),
                                                                            "longitude" to
                                                                                    (result.targetPos
                                                                                            ?.longitude
                                                                                            ?: 0.0)
                                                                    ),
                                                            "paths" to
                                                                    (result.paths ?: emptyList())
                                                                            .map { path ->
                                                                                mapOf(
                                                                                        "steps" to
                                                                                                (path?.steps
                                                                                                                ?: emptyList())
                                                                                                        .map {
                                                                                                                step
                                                                                                            ->
                                                                                                            mapOf(
                                                                                                                    "road" to
                                                                                                                            (step?.road
                                                                                                                                    ?: ""),
                                                                                                                    "polyline" to
                                                                                                                            (step?.polyline
                                                                                                                                            ?: emptyList())
                                                                                                                                    .map {
                                                                                                                                            point
                                                                                                                                        ->
                                                                                                                                        mapOf(
                                                                                                                                                "latitude" to
                                                                                                                                                        (point?.latitude
                                                                                                                                                                ?: 0.0),
                                                                                                                                                "longitude" to
                                                                                                                                                        (point?.longitude
                                                                                                                                                                ?: 0.0)
                                                                                                                                        )
                                                                                                                                    },
                                                                                                                    "distance" to
                                                                                                                            (step?.distance
                                                                                                                                    ?: 0),
                                                                                                                    "duration" to
                                                                                                                            (step?.duration
                                                                                                                                    ?: 0),
                                                                                                                    "action" to
                                                                                                                            (step?.action
                                                                                                                                    ?: ""),
                                                                                                                    "assistantAction" to
                                                                                                                            (step?.assistantAction
                                                                                                                                    ?: ""),
                                                                                                                    "instruction" to
                                                                                                                            (step?.instruction
                                                                                                                                    ?: ""),
                                                                                                                    "orientation" to
                                                                                                                            (step?.orientation
                                                                                                                                    ?: 0)
                                                                                                            )
                                                                                                        },
                                                                                        "distance" to
                                                                                                (path?.distance
                                                                                                        ?: 0),
                                                                                        "duration" to
                                                                                                (path?.duration
                                                                                                        ?: 0),
                                                                                        "polyline" to
                                                                                                (path?.polyline
                                                                                                                ?: emptyList())
                                                                                                        .map {
                                                                                                                point
                                                                                                            ->
                                                                                                            mapOf(
                                                                                                                    "latitude" to
                                                                                                                            (point?.latitude
                                                                                                                                    ?: 0.0),
                                                                                                                    "longitude" to
                                                                                                                            (point?.longitude
                                                                                                                                    ?: 0.0)
                                                                                                            )
                                                                                                        }
                                                                                )
                                                                            }
                                                    )
                                    )
                            )
                        } else {
                            promise.reject(
                                    "ROUTE_ERROR",
                                    "Route search failed with code: $errorCode",
                                    null
                            )
                        }
                    }

                    override fun onDriveRouteSearched(result: DriveRouteResult?, errorCode: Int) {}
                    override fun onBusRouteSearched(result: BusRouteResult?, errorCode: Int) {}
                    override fun onRideRouteSearched(result: RideRouteResult?, errorCode: Int) {}
                }
        )
        routeSearch.calculateWalkRouteAsyn(query)
    }

    fun searchRidingRoute(options: SearchRidingRouteOptions, promise: Promise) {
        val originPoint = LatLonPoint(options.origin.latitude, options.origin.longitude)
        val destPoint = LatLonPoint(options.destination.latitude, options.destination.longitude)
        val fromAndTo = RouteSearch.FromAndTo(originPoint, destPoint)

        val query = RouteSearch.RideRouteQuery(fromAndTo)

        routeSearch.setRouteSearchListener(
                object : RouteSearch.OnRouteSearchListener {
                    override fun onWalkRouteSearched(result: WalkRouteResult?, errorCode: Int) {}
                    override fun onDriveRouteSearched(result: DriveRouteResult?, errorCode: Int) {}
                    override fun onBusRouteSearched(result: BusRouteResult?, errorCode: Int) {}
                    override fun onRideRouteSearched(result: RideRouteResult?, errorCode: Int) {
                        if (errorCode == 1000 && result != null) { // 1000 表示成功
                            promise.resolve(
                                    mapOf(
                                            "success" to true,
                                            "count" to result.paths.size,
                                            "route" to
                                                    mapOf(
                                                            "origin" to
                                                                    mapOf(
                                                                            "latitude" to
                                                                                    (result.startPos
                                                                                            ?.latitude
                                                                                            ?: 0.0),
                                                                            "longitude" to
                                                                                    (result.startPos
                                                                                            ?.longitude
                                                                                            ?: 0.0)
                                                                    ),
                                                            "destination" to
                                                                    mapOf(
                                                                            "latitude" to
                                                                                    (result.targetPos
                                                                                            ?.latitude
                                                                                            ?: 0.0),
                                                                            "longitude" to
                                                                                    (result.targetPos
                                                                                            ?.longitude
                                                                                            ?: 0.0)
                                                                    ),
                                                            "paths" to
                                                                    (result.paths ?: emptyList())
                                                                            .map { path ->
                                                                                mapOf(
                                                                                        "steps" to
                                                                                                (path?.steps
                                                                                                                ?: emptyList())
                                                                                                        .map {
                                                                                                                step
                                                                                                            ->
                                                                                                            mapOf(
                                                                                                                    "road" to
                                                                                                                            (step?.road
                                                                                                                                    ?: ""),
                                                                                                                    "polyline" to
                                                                                                                            (step?.polyline
                                                                                                                                            ?: emptyList())
                                                                                                                                    .map {
                                                                                                                                            point
                                                                                                                                        ->
                                                                                                                                        mapOf(
                                                                                                                                                "latitude" to
                                                                                                                                                        (point?.latitude
                                                                                                                                                                ?: 0.0),
                                                                                                                                                "longitude" to
                                                                                                                                                        (point?.longitude
                                                                                                                                                                ?: 0.0)
                                                                                                                                        )
                                                                                                                                    },
                                                                                                                    "distance" to
                                                                                                                            (step?.distance
                                                                                                                                    ?: 0),
                                                                                                                    "duration" to
                                                                                                                            (step?.duration
                                                                                                                                    ?: 0),
                                                                                                                    "action" to
                                                                                                                            (step?.action
                                                                                                                                    ?: ""),
                                                                                                                    "assistantAction" to
                                                                                                                            (step?.assistantAction
                                                                                                                                    ?: ""),
                                                                                                                    "instruction" to
                                                                                                                            (step?.instruction
                                                                                                                                    ?: ""),
                                                                                                                    "orientation" to
                                                                                                                            (step?.orientation
                                                                                                                                    ?: 0)
                                                                                                            )
                                                                                                        },
                                                                                        "distance" to
                                                                                                (path?.distance
                                                                                                        ?: 0),
                                                                                        "duration" to
                                                                                                (path?.duration
                                                                                                        ?: 0),
                                                                                        "polyline" to
                                                                                                (path?.polyline
                                                                                                                ?: emptyList())
                                                                                                        .map {
                                                                                                                point
                                                                                                            ->
                                                                                                            mapOf(
                                                                                                                    "latitude" to
                                                                                                                            (point?.latitude
                                                                                                                                    ?: 0.0),
                                                                                                                    "longitude" to
                                                                                                                            (point?.longitude
                                                                                                                                    ?: 0.0)
                                                                                                            )
                                                                                                        }
                                                                                )
                                                                            }
                                                    )
                                    )
                            )
                        } else {
                            promise.reject(
                                    "ROUTE_ERROR",
                                    "Route search failed with code: $errorCode",
                                    null
                            )
                        }
                    }
                }
        )
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

        routeSearch.setRouteSearchListener(
                object : RouteSearch.OnRouteSearchListener {
                    override fun onWalkRouteSearched(result: WalkRouteResult?, errorCode: Int) {}
                    override fun onDriveRouteSearched(result: DriveRouteResult?, errorCode: Int) {}
                    override fun onBusRouteSearched(result: BusRouteResult?, errorCode: Int) {
                        if (errorCode == 1000 && result != null) { // 1000 表示成功
                            promise.resolve(
                                    mapOf(
                                            "success" to true,
                                            "count" to result.paths.size,
                                            "route" to
                                                    mapOf(
                                                            "origin" to
                                                                    mapOf(
                                                                            "latitude" to
                                                                                    (result.startPos
                                                                                            ?.latitude
                                                                                            ?: 0.0),
                                                                            "longitude" to
                                                                                    (result.startPos
                                                                                            ?.longitude
                                                                                            ?: 0.0)
                                                                    ),
                                                            "destination" to
                                                                    mapOf(
                                                                            "latitude" to
                                                                                    (result.targetPos
                                                                                            ?.latitude
                                                                                            ?: 0.0),
                                                                            "longitude" to
                                                                                    (result.targetPos
                                                                                            ?.longitude
                                                                                            ?: 0.0)
                                                                    ),
                                                            "paths" to
                                                                    (result.paths ?: emptyList())
                                                                            .map { path ->
                                                                                mapOf(
                                                                                        "steps" to
                                                                                                (path?.steps
                                                                                                                ?: emptyList())
                                                                                                        .map {
                                                                                                                step
                                                                                                            ->
                                                                                                            mapOf(
                                                                                                                    "road" to
                                                                                                                            (step?.busLines
                                                                                                                                            ?: emptyList())
                                                                                                                                    .map {
                                                                                                                                            busLine
                                                                                                                                        ->
                                                                                                                                        mapOf(
                                                                                                                                                "duration" to
                                                                                                                                                        (busLine?.duration
                                                                                                                                                                ?: 0),
                                                                                                                                                "distance" to
                                                                                                                                                        (busLine?.distance
                                                                                                                                                                ?: 0),
                                                                                                                                                "busLineId" to
                                                                                                                                                        (busLine?.busLineId
                                                                                                                                                                ?: ""),
                                                                                                                                                "cityCode" to
                                                                                                                                                        (busLine?.cityCode
                                                                                                                                                                ?: ""),
                                                                                                                                                "polyline" to
                                                                                                                                                        (busLine?.polyline
                                                                                                                                                                        ?: emptyList())
                                                                                                                                                                .map {
                                                                                                                                                                        point
                                                                                                                                                                    ->
                                                                                                                                                                    mapOf(
                                                                                                                                                                            "latitude" to
                                                                                                                                                                                    (point?.latitude
                                                                                                                                                                                            ?: 0.0),
                                                                                                                                                                            "longitude" to
                                                                                                                                                                                    (point?.longitude
                                                                                                                                                                                            ?: 0.0)
                                                                                                                                                                    )
                                                                                                                                                                },
                                                                                                                                                "arrivalBusStation" to
                                                                                                                                                        mapOf(
                                                                                                                                                                "adCode" to
                                                                                                                                                                        (busLine?.arrivalBusStation
                                                                                                                                                                                ?.adCode
                                                                                                                                                                                ?: ""),
                                                                                                                                                                "cityCode" to
                                                                                                                                                                        (busLine?.arrivalBusStation
                                                                                                                                                                                ?.cityCode
                                                                                                                                                                                ?: ""),
                                                                                                                                                                "busStationId" to
                                                                                                                                                                        (busLine?.arrivalBusStation
                                                                                                                                                                                ?.busStationId
                                                                                                                                                                                ?: ""),
                                                                                                                                                                "busStationName" to
                                                                                                                                                                        (busLine?.arrivalBusStation
                                                                                                                                                                                ?.busStationName
                                                                                                                                                                                ?: ""),
                                                                                                                                                                "busLineItems" to
                                                                                                                                                                        (busLine?.arrivalBusStation
                                                                                                                                                                                ?.busLineItems
                                                                                                                                                                                ?: emptyList<
                                                                                                                                                                                        Any>()),
                                                                                                                                                                "latLonPoint" to
                                                                                                                                                                        mapOf(
                                                                                                                                                                                "latitude" to
                                                                                                                                                                                        (busLine?.arrivalBusStation
                                                                                                                                                                                                ?.latLonPoint
                                                                                                                                                                                                ?.latitude
                                                                                                                                                                                                ?: 0.0),
                                                                                                                                                                                "longitude" to
                                                                                                                                                                                        (busLine?.arrivalBusStation
                                                                                                                                                                                                ?.latLonPoint
                                                                                                                                                                                                ?.longitude
                                                                                                                                                                                                ?: 0.0)
                                                                                                                                                                        )
                                                                                                                                                        )
                                                                                                                                        )
                                                                                                                                    },
                                                                                                                    "exit" to
                                                                                                                            mapOf(
                                                                                                                                    "name" to
                                                                                                                                            (step?.exit
                                                                                                                                                    ?.name
                                                                                                                                                    ?: ""),
                                                                                                                                    "latLonPoint" to
                                                                                                                                            mapOf(
                                                                                                                                                    "latitude" to
                                                                                                                                                            (step?.exit
                                                                                                                                                                    ?.latLonPoint
                                                                                                                                                                    ?.latitude
                                                                                                                                                                    ?: 0.0),
                                                                                                                                                    "longitude" to
                                                                                                                                                            (step?.exit
                                                                                                                                                                    ?.latLonPoint
                                                                                                                                                                    ?.longitude
                                                                                                                                                                    ?: 0.0)
                                                                                                                                            )
                                                                                                                            ),
                                                                                                                    "taxi" to
                                                                                                                            mapOf(
                                                                                                                                    "origin" to
                                                                                                                                            mapOf(
                                                                                                                                                    "latitude" to
                                                                                                                                                            (step?.taxi
                                                                                                                                                                    ?.origin
                                                                                                                                                                    ?.latitude
                                                                                                                                                                    ?: 0.0),
                                                                                                                                                    "longitude" to
                                                                                                                                                            (step?.taxi
                                                                                                                                                                    ?.origin
                                                                                                                                                                    ?.longitude
                                                                                                                                                                    ?: 0.0)
                                                                                                                                            ),
                                                                                                                                    "destination" to
                                                                                                                                            mapOf(
                                                                                                                                                    "latitude" to
                                                                                                                                                            (step?.taxi
                                                                                                                                                                    ?.destination
                                                                                                                                                                    ?.latitude
                                                                                                                                                                    ?: 0.0),
                                                                                                                                                    "longitude" to
                                                                                                                                                            (step?.taxi
                                                                                                                                                                    ?.destination
                                                                                                                                                                    ?.longitude
                                                                                                                                                                    ?: 0.0)
                                                                                                                                            ),
                                                                                                                                    "distance" to
                                                                                                                                            (step?.taxi
                                                                                                                                                    ?.distance
                                                                                                                                                    ?: 0),
                                                                                                                                    "duration" to
                                                                                                                                            (step?.taxi
                                                                                                                                                    ?.duration
                                                                                                                                                    ?: 0)
                                                                                                                            ),
                                                                                                                    "walk" to
                                                                                                                            mapOf(
                                                                                                                                    "distance" to
                                                                                                                                            (step?.walk
                                                                                                                                                    ?.distance
                                                                                                                                                    ?: 0),
                                                                                                                                    "duration" to
                                                                                                                                            (step?.walk
                                                                                                                                                    ?.duration
                                                                                                                                                    ?: 0),
                                                                                                                                    "polyline" to
                                                                                                                                            (step?.walk
                                                                                                                                                            ?.polyline
                                                                                                                                                            ?: emptyList())
                                                                                                                                                    .map {
                                                                                                                                                            point
                                                                                                                                                        ->
                                                                                                                                                        mapOf(
                                                                                                                                                                "latitude" to
                                                                                                                                                                        (point?.latitude
                                                                                                                                                                                ?: 0.0),
                                                                                                                                                                "longitude" to
                                                                                                                                                                        (point?.longitude
                                                                                                                                                                                ?: 0.0)
                                                                                                                                                        )
                                                                                                                                                    },
                                                                                                                                    "origin" to
                                                                                                                                            mapOf(
                                                                                                                                                    "latitude" to
                                                                                                                                                            (step?.walk
                                                                                                                                                                    ?.origin
                                                                                                                                                                    ?.latitude
                                                                                                                                                                    ?: 0.0),
                                                                                                                                                    "longitude" to
                                                                                                                                                            (step?.walk
                                                                                                                                                                    ?.origin
                                                                                                                                                                    ?.longitude
                                                                                                                                                                    ?: 0.0)
                                                                                                                                            ),
                                                                                                                                    "destination" to
                                                                                                                                            mapOf(
                                                                                                                                                    "latitude" to
                                                                                                                                                            (step?.walk
                                                                                                                                                                    ?.destination
                                                                                                                                                                    ?.latitude
                                                                                                                                                                    ?: 0.0),
                                                                                                                                                    "longitude" to
                                                                                                                                                            (step?.walk
                                                                                                                                                                    ?.destination
                                                                                                                                                                    ?.longitude
                                                                                                                                                                    ?: 0.0)
                                                                                                                                            )
                                                                                                                            )
                                                                                                            )
                                                                                                        },
                                                                                        "distance" to
                                                                                                (path?.distance
                                                                                                        ?: 0),
                                                                                        "duration" to
                                                                                                (path?.duration
                                                                                                        ?: 0),
                                                                                        "polyline" to
                                                                                                (path?.polyline
                                                                                                                ?: emptyList())
                                                                                                        .map {
                                                                                                                point
                                                                                                            ->
                                                                                                            mapOf(
                                                                                                                    "latitude" to
                                                                                                                            (point?.latitude
                                                                                                                                    ?: 0.0),
                                                                                                                    "longitude" to
                                                                                                                            (point?.longitude
                                                                                                                                    ?: 0.0)
                                                                                                            )
                                                                                                        }
                                                                                )
                                                                            }
                                                    )
                                    )
                            )
                        } else {
                            promise.reject(
                                    "ROUTE_ERROR",
                                    "Route search failed with code: $errorCode",
                                    null
                            )
                        }
                    }

                    override fun onRideRouteSearched(result: RideRouteResult?, errorCode: Int) {}
                }
        )
        routeSearch.calculateBusRouteAsyn(query)
    }
}
