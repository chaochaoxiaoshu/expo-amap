//
//  Base.swift
//  Pods
//
//  Created by 朝小树 on 2025/8/13.
//
import ExpoModulesCore

struct Size: Record {
    @Field var width: Double
    @Field var height: Double
}

struct Point: Record {
    @Field var x: Double
    @Field var y: Double
}

struct CoordinatePlain {
    var latitude: Double
    var longitude: Double
}

struct Coordinate: Record {
    @Field var latitude: Double
    @Field var longitude: Double
}
