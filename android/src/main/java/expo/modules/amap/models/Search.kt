package expo.modules.amap.models

import expo.modules.kotlin.records.Field
import expo.modules.kotlin.records.Record
import expo.modules.kotlin.types.Enumerable

class SearchInputTipsOptions: Record {
    @Field var keywords: String = ""
    @Field var city: String? = null
    @Field var types: String? = null
    @Field var cityLimit: Boolean? = null
    @Field var location: String? = null
}

class SearchGeocodeOptions: Record {
    @Field var address: String? = null
    @Field var city: String? = null
    @Field var country: String? = null
}

class SearchReGeocodeOptions: Record {
    @Field var requireExtension: Boolean? = null
    @Field var location: Coordinate? = null
    @Field var radius: Int? = null
    @Field var poitype: String? = null
    @Field var mode: String? = null
}

enum class DrivingRouteShowFieldType(val value: String): Enumerable {
    NONE("none"),
    COST("cost"),
    TMCS("tmcs"),
    NAVI("navi"),
    CITIES("cities"),
    POLYLINE("polyline"),
    NEW_ENERGY("newEnergy"),
    ALL("all")
}

class SearchDrivingRouteOptions: Record {
    @Field var origin: Coordinate = Coordinate()
    @Field var destination: Coordinate = Coordinate()
    @Field var showFieldType: DrivingRouteShowFieldType = DrivingRouteShowFieldType.POLYLINE
}

enum class WalkingRouteShowFieldType(val value: String): Enumerable {
    NONE("none"),
    COST("cost"),
    NAVI("navi"),
    POLYLINE("polyline"),
    ALL("all")
}

class SearchWalkingRouteOptions: Record {
    @Field var origin: Coordinate = Coordinate()
    @Field var destination: Coordinate = Coordinate()
    @Field var showFieldType: WalkingRouteShowFieldType = WalkingRouteShowFieldType.POLYLINE
}

enum class RidingRouteShowFieldType(val value: String): Enumerable {
    NONE("none"),
    COST("cost"),
    NAVI("navi"),
    POLYLINE("polyline"),
    ALL("all")
}

class SearchRidingRouteOptions: Record {
    @Field var origin: Coordinate = Coordinate()
    @Field var destination: Coordinate = Coordinate()
    @Field var alternativeRoute: Int = 0
    @Field var showFieldType: RidingRouteShowFieldType = RidingRouteShowFieldType.POLYLINE
}

enum class TransitRouteShowFieldType(val value: String): Enumerable {
    NONE("none"),
    COST("cost"),
    NAVI("navi"),
    POLYLINE("polyline"),
    ALL("all")
}

class SearchTransitRouteOptions: Record {
    @Field var origin: Coordinate = Coordinate()
    @Field var destination: Coordinate = Coordinate()
    @Field var strategy: Int = 0
    @Field var city: String = ""
    @Field var destinationCity: String = ""
    @Field var nightflag: Boolean = false
    @Field var originPOI: String? = null
    @Field var destinationPOI: String? = null
    @Field var adcode: String? = null
    @Field var destinationAdcode: String? = null
    @Field var alternativeRoute: Int? = null
    @Field var multiExport: Boolean? = null
    @Field var maxTrans: Int? = null
    @Field var date: String? = null
    @Field var time: String? = null
    @Field var showFieldType: TransitRouteShowFieldType = TransitRouteShowFieldType.POLYLINE
}