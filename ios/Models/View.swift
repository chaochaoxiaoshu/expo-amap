//
//  View.swift
//  Pods
//
//  Created by 朝小树 on 2025/8/13.
//
import ExpoModulesCore

struct RegionSpan: Record {
    @Field var latitudeDelta: Double
    @Field var longitudeDelta: Double
}

struct Region: Record {
    @Field var center: Coordinate
    @Field var span: RegionSpan
}

struct PathShowRange: Record {
    @Field var begin: Double
    @Field var end: Double
}

struct PolylineStyle: Record {
    @Field var fillColor: String?
    @Field var strokeColor: String?
    @Field var lineWidth: Double?
    @Field var lineJoinType: Int?
    @Field var lineCapType: Int?
    @Field var miterLimit: Double?
    @Field var lineDashType: Int?
    @Field var reducePoint: Bool?
    @Field var is3DArrowLine: Bool?
    @Field var sideColor: String?
    @Field var userInteractionEnabled: Bool?
    @Field var hitTestInset: Double?
    @Field var showRangeEnabled: Bool?
    @Field var pathShowRange: PathShowRange?
    @Field var textureImage: String?
}

struct Polyline: Record {
    @Field var coordinates: [Coordinate]
    @Field var style: PolylineStyle
}

struct TextStyle: Record {
    @Field var color: String?
    @Field var fontSize: Double?
    @Field var fontWeight: String?
    @Field var numberOfLines: Int?
    @Field var padding: Point?
    @Field var backgroundColor: String?
}

struct MarkerImage: Record {
    @Field var url: String
    @Field var size: Size
}

struct MarkerExtra: Record {
    @Field var province: String?
    @Field var city: String?
    @Field var district: String?
}

struct Marker: Record {
    @Field var id: String
    @Field var coordinate: Coordinate
    @Field var style: String?
    @Field var title: String?
    @Field var subtitle: String?
    @Field var centerOffset: Point?
    @Field var calloutOffset: Point?
    @Field var textOffset: Point?
    @Field var image: MarkerImage?
    @Field var textStyle: TextStyle?
    @Field var pinColor: Int?
    @Field var teardropLabel: String?
    @Field var teardropRandomFillColorSeed: String?
    @Field var teardropFillColor: String?
    @Field var enabled: Bool?
    @Field var highlighted: Bool?
    @Field var canShowCallout: Bool?
    @Field var draggable: Bool?
    @Field var canAdjustPosition: Bool?
    @Field var extra: MarkerExtra?
    @Field var customCalloutViewTag: Int?
}

struct CustomStyle: Record {
    @Field var enabled: Bool
    @Field var styleData: [UInt8]?
    @Field var styleExtraData: [UInt8]?
}

struct RegionClusteringRule: Record {
    @Field var by: String
    @Field var thresholdZoomLevel: Double
}

struct RegionClusteringOptions: Record {
    @Field var enabled: Bool?
    @Field var rules: [RegionClusteringRule]
}
