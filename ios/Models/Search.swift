//
//  Search.swift
//  Pods
//
//  Created by 朝小树 on 2025/8/13.
//
import ExpoModulesCore

struct SearchInputTipsOptions: Record {
    @Field var keywords: String
    @Field var city: String?
    @Field var types: String?
    @Field var cityLimit: Bool?
    @Field var location: String?
}

struct SearchGeocodeOptions: Record {
    @Field var address: String?
    @Field var city: String?
    @Field var country: String?
}

struct SearchReGeocodeOptions: Record {
    @Field var requireExtension: Bool?
    @Field var location: Coordinate?
    @Field var radius: Int?
    @Field var poitype: String?
    @Field var mode: String?
}

enum DrivingRouteShowFieldType: String, Enumerable {
    case none
    case cost
    case tmcs
    case navi
    case cities
    case polyline
    case newEnergy
    case all
}

struct SearchDrivingRouteOptions: Record {
    @Field var origin: Coordinate
    @Field var destination: Coordinate
    @Field var showFieldType: DrivingRouteShowFieldType = .polyline
}

enum WalkingRouteShowFieldType: String, Enumerable {
    case none
    case cost
    case navi
    case polyline
    case all
}

struct SearchWalkingRouteOptions: Record {
    @Field var origin: Coordinate
    @Field var destination: Coordinate
    @Field var showFieldType: WalkingRouteShowFieldType = .polyline
}

enum RidingRouteShowFieldType: String, Enumerable {
    case none
    case cost
    case navi
    case polyline
    case all
}

struct SearchRidingRouteOptions: Record {
    @Field var origin: Coordinate
    @Field var destination: Coordinate
    @Field var alternativeRoute: Int
    @Field var showFieldType: RidingRouteShowFieldType = .polyline
}

enum TransitRouteShowFieldType: String, Enumerable {
    case none
    case cost
    case navi
    case polyline
    case all
}

struct SearchTransitRouteOptions: Record {
    @Field var origin: Coordinate
    @Field var destination: Coordinate
    @Field var strategy: Int
    @Field var city: String
    @Field var destinationCity: String
    @Field var nightflag: Bool
    @Field var originPOI: String?
    @Field var destinationPOI: String?
    @Field var adcode: String?
    @Field var destinationAdcode: String?
    @Field var alternativeRoute: Int?
    @Field var multiExport: Bool?
    @Field var maxTrans: Int?
    @Field var date: String?
    @Field var time: String?
    @Field var showFieldType: TransitRouteShowFieldType = .polyline
}
