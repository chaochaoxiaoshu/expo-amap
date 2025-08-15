package expo.modules.amap

import android.content.Context
import com.amap.api.maps.AMap
import com.amap.api.maps.model.LatLng
import com.amap.api.maps.model.Polyline
import com.amap.api.maps.model.PolylineOptions
import expo.modules.amap.models.Polyline as PolylineData

class PolylineManager(private val map: AMap, private val context: Context) {
    private val polylines: MutableList<Polyline> = mutableListOf()

    fun setPolyLines(polylines: Array<PolylineData>) {
        this.polylines.forEach { it.remove() }
        this.polylines.clear()

        polylines.forEach { data ->
            val density = context.resources.displayMetrics.density

            val options = PolylineOptions()
                .addAll(data.coordinates.map { LatLng(it.latitude, it.longitude) })
                .width(data.style.lineWidth?.toFloat()?.times(density) ?: 5f)
                .color(data.style.strokeColor?.toSafeColorInt() ?: 0xFF000000.toInt())
                .setDottedLine(data.style.lineDashType != null && data.style.lineDashType != 0)
                .setUseTexture(data.style.textureImage != null)

            when (data.style.lineDashType) {
                1 -> options.setDottedLineType(0)
                2 -> options.setDottedLineType(1)
            }

            when (data.style.lineJoinType) {
                0 -> options.lineJoinType(PolylineOptions.LineJoinType.LineJoinMiter)
                1 -> options.lineJoinType(PolylineOptions.LineJoinType.LineJoinBevel)
                2 -> options.lineJoinType(PolylineOptions.LineJoinType.LineJoinRound)
            }

            when (data.style.lineCapType) {
                0 -> options.lineCapType(PolylineOptions.LineCapType.LineCapButt)
                1 -> options.lineCapType(PolylineOptions.LineCapType.LineCapSquare)
                2 -> options.lineCapType(PolylineOptions.LineCapType.LineCapArrow)
                3 -> options.lineCapType(PolylineOptions.LineCapType.LineCapRound)
            }

            val polyline = map.addPolyline(options)
            this.polylines.add(polyline)
        }
    }
}