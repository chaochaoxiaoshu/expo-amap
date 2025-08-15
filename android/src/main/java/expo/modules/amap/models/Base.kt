package expo.modules.amap.models

import expo.modules.kotlin.records.Field
import expo.modules.kotlin.records.Record

class Size: Record {
    @Field var width: Double = 0.0
    @Field var height: Double = 0.0
}

class Point: Record {
    @Field var x: Double = 0.0
    @Field var y: Double = 0.0
}

class CoordinatePlain {
    var latitude: Double = 0.0
    var longitude: Double = 0.0
}

class Coordinate: Record {
    @Field var latitude: Double = 0.0
    @Field var longitude: Double = 0.0
}