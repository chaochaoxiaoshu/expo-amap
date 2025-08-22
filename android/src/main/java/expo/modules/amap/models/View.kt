package expo.modules.amap.models

import expo.modules.kotlin.records.Field
import expo.modules.kotlin.records.Record

class RegionSpan: Record {
    @Field var latitudeDelta: Double = 0.0
    @Field var longitudeDelta: Double = 0.0
}

class Region: Record {
    @Field var center: Coordinate = Coordinate()
    @Field var span: RegionSpan = RegionSpan()
}

class PathShowRange: Record {
    @Field var begin: Double = 0.0
    @Field var end: Double = 0.0
}

class PolylineStyle: Record {
    @Field var fillColor: String? = null
    @Field var strokeColor: String? = null
    @Field var lineWidth: Double? = null
    @Field var lineJoinType: Int? = null
    @Field var lineCapType: Int? = null
    @Field var miterLimit: Double? = null
    @Field var lineDashType: Int? = null
    @Field var reducePoint: Boolean? = null
    @Field var is3DArrowLine: Boolean? = null
    @Field var sideColor: String? = null
    @Field var userInteractionEnabled: Boolean? = null
    @Field var hitTestInset: Double? = null
    @Field var showRangeEnabled: Boolean? = null
    @Field var pathShowRange: PathShowRange? = null
    @Field var textureImage: String? = null
}

class Polyline: Record {
    @Field var coordinates: Array<Coordinate> = arrayOf()
    @Field var style: PolylineStyle = PolylineStyle()
}

class TextStyle: Record {
    @Field var color: String? = null
    @Field var fontSize: Double? = null
    @Field var fontWeight: String? = null
    @Field var numberOfLines: Int? = null
    @Field var padding: Point? = null
    @Field var backgroundColor: String? = null
}

class MarkerImage: Record {
    @Field var url: String = ""
    @Field var size: Size = Size()
}

class MarkerExtra: Record {
    @Field var province: String? = null
    @Field var city: String? = null
    @Field var district: String? = null
}

class Marker: Record {
    @Field var id: String = ""
    @Field var coordinate: Coordinate = Coordinate()
    @Field var style: String? = null
    @Field var title: String? = null
    @Field var subtitle: String? = null
    @Field var centerOffset: Point? = null
    @Field var calloutOffset: Point? = null
    @Field var textOffset: Point? = null
    @Field var image: MarkerImage? = null
    @Field var textStyle: TextStyle? = null
    @Field var pinColor: Int? = null
    @Field var teardropLabel: String? = null
    @Field var teardropRandomFillColorSeed: String? = null
    @Field var teardropFillColor: String? = null
    @Field var teardropInfoText: String? = null
    @Field var enabled: Boolean? = null
    @Field var highlighted: Boolean? = null
    @Field var canShowCallout: Boolean? = null
    @Field var draggable: Boolean? = null
    @Field var canAdjustPosition: Boolean? = null
    @Field var extra: MarkerExtra? = null
}

class CustomStyle: Record {
    @Field var enabled: Boolean = false
    @Field var styleData: ByteArray? = null
    @Field var styleExtraData: ByteArray? = null
}

class RegionClusteringRule: Record {
    @Field var by: String = ""
    @Field var thresholdZoomLevel: Double = 0.0
}

class RegionClusteringOptions: Record {
    @Field var enabled: Boolean? = null
    @Field var rules: Array<RegionClusteringRule> = arrayOf()
}