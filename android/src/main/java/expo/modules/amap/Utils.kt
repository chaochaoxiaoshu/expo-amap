package expo.modules.amap

import expo.modules.amap.models.Region
import kotlin.math.ln
import kotlin.math.pow

object Utils {

    fun mapCameraPositionToRegion(position: com.amap.api.maps.model.CameraPosition?, mapViewWidth: Int, mapViewHeight: Int): Map<String, Any> {
        if (position == null) return mapOf()

        val lat = position.target.latitude
        val lng = position.target.longitude
        val zoom = position.zoom
        val span = zoomToRegionSpan(zoom, mapViewWidth, mapViewHeight)

        return mapOf(
            "center" to mapOf(
                "latitude" to lat,
                "longitude" to lng
            ),
            "span" to span
        )
    }

    fun zoomToRegionSpan(zoom: Float?, width: Int, height: Int): Map<String, Double> {
        if (zoom == null) return mapOf(
            "latitudeDelta" to 0.0,
            "longitudeDelta" to 0.0
        )

        val scale = 360 / 2.0.pow(zoom.toDouble())
        val latitudeDelta = scale
        val longitudeDelta = scale * width / height

        return mapOf(
            "latitudeDelta" to latitudeDelta,
            "longitudeDelta" to longitudeDelta
        )
    }

    fun regionToZoomLevel(region: Region, mapViewWidth: Int, mapViewHeight: Int): Float {
        val aspectRatio = mapViewWidth.toDouble() / mapViewHeight.toDouble()

        val zoomLat = ln(360 / region.span.latitudeDelta) / ln(2.0)
        val zoomLng = ln(360 * aspectRatio / region.span.longitudeDelta) / ln(2.0)

        return zoomLat.coerceAtMost(zoomLng).toFloat()
    }
}
