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
    @Field var title: String?
    @Field var subtitle: String?
    @Field var zIndex: Int?
    @Field var image: MarkerImage?
    @Field var centerOffset: Point?
    @Field var calloutOffset: Point?
    @Field var textOffset: Point?
    @Field var enabled: Bool?
    @Field var highlighted: Bool?
    @Field var canShowCallout: Bool?
    @Field var draggable: Bool?
    @Field var canAdjustPosition: Bool?
    @Field var textStyle: TextStyle?
    @Field var pinColor: Int?
    @Field var extra: MarkerExtra?
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
