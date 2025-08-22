package expo.modules.amap

import android.content.Context
import android.graphics.Color
import com.amap.api.maps.AMap
import com.amap.api.maps.model.BitmapDescriptorFactory
import com.amap.api.maps.model.LatLng
import com.amap.api.maps.model.Marker as AMapMarker
import com.amap.api.maps.model.MarkerOptions
import expo.modules.amap.models.Marker
import expo.modules.amap.models.RegionClusteringOptions
import expo.modules.amap.models.RegionClusteringRule

class MarkerManager(private val map: AMap, private val context: Context) {
    private data class NormalMarker(val marker: AMapMarker, val style: String?)
    private val normalMarkers: MutableList<NormalMarker> = mutableListOf()
    private data class ClusterMarker(val marker: AMapMarker, val by: String)
    private val clusterMarkers: MutableList<ClusterMarker> = mutableListOf()
    private val dataMarkers: MutableList<Marker> = mutableListOf()

    var regionClusteringOptions: RegionClusteringOptions? = null

    fun setMarkers(markers: Array<Marker>) {
        // 清除旧的普通标记
        normalMarkers.forEach { it.marker.remove() }
        normalMarkers.clear()
        dataMarkers.clear()
        dataMarkers.addAll(markers)

        // 新增标记
        markers.forEach { data ->
            val position = LatLng(data.coordinate.latitude, data.coordinate.longitude)
            val options =
                    MarkerOptions().position(position).title(data.title).snippet(data.subtitle)

            when (data.style ?: "pin") {
                "pin" -> {
                    // 默认大头针
                    // 支持 pinColor（与 iOS 的 MAPinAnnotationColor 对齐：0 red, 1 green, 2 purple）
                    data.pinColor?.let { raw ->
                        val hue =
                                when (raw) {
                                    1 -> BitmapDescriptorFactory.HUE_GREEN
                                    2 -> BitmapDescriptorFactory.HUE_VIOLET
                                    else -> BitmapDescriptorFactory.HUE_RED
                                }
                        options.icon(BitmapDescriptorFactory.defaultMarker(hue))
                    }
                }
                "teardrop" -> {
                    val view = TeardropMarkerView(context)
                    // 文本标签
                    data.teardropLabel?.let { view.label = it }
                    // 填充色（优先明确颜色，其次种子色，否则默认）
                    val defaultColor = "#5981D8".toSafeColorInt()
                    val fillColor =
                            when {
                                data.teardropFillColor != null ->
                                        data.teardropFillColor!!.toSafeColorInt()
                                data.teardropRandomFillColorSeed != null ->
                                        colorFromSeed(data.teardropRandomFillColorSeed!!)
                                else -> defaultColor
                            }
                    view.teardropFillColor = fillColor
                    // 信息文本（可选）
                    view.infoText = data.teardropInfoText

                    val bmp = view.toBitmap()
                    options.icon(BitmapDescriptorFactory.fromBitmap(bmp))
                    // 锚点在底部中间，使水滴尖端对准坐标
                    options.anchor(0.5f, 1.0f)
                }
                "custom" -> {
                    val view = TextAnnotationView(context)
                    // 文本：优先 title，其次 subtitle
                    view.setText(data.title?.takeIf { it.isNotEmpty() } ?: data.subtitle)
                    // 文本样式
                    view.textStyle = data.textStyle
                    // 偏移
                    view.textOffset = data.textOffset

                    // 图片（异步加载尺寸生效）
                    val imgUrl = data.image?.url
                    if (imgUrl != null) {
                        ImageLoader.from(imgUrl) { bmp ->
                            view.setImage(bmp, data.image?.size)
                            val bitmap = view.toBitmap()
                            val opt =
                                    MarkerOptions()
                                            .position(position)
                                            .icon(BitmapDescriptorFactory.fromBitmap(bitmap))
                                            .anchor(0.5f, 0.5f)
                            val m = map.addMarker(opt)
                            if (m != null) normalMarkers.add(NormalMarker(m, data.style))
                        }
                        // 跳过后续 addMarker，由回调中完成
                        return@forEach
                    }

                    val bitmap = view.toBitmap()
                    options.icon(BitmapDescriptorFactory.fromBitmap(bitmap))
                    options.anchor(0.5f, 0.5f)
                }
                else -> {
                    // 其他样式暂未实现，回退到默认
                }
            }

            val marker = map.addMarker(options)
            if (marker != null) {
                normalMarkers.add(NormalMarker(marker, data.style))
            }
        }

        // 重新计算聚合标记
        calculateClusterMarkers()
    }

    private fun colorFromSeed(seed: String): Int {
        // 使用稳定的调色盘，避免出现偏棕的色调
        val palette =
                listOf(
                        "#5981D8", // blue
                        "#FF5252", // red
                        "#4CAF50", // green
                        "#FFC107", // amber
                        "#9C27B0", // purple
                        "#00BCD4", // cyan
                        "#FF9800", // orange
                        "#3F51B5", // indigo
                        "#E91E63", // pink
                        "#8BC34A" // light green
                )
        val idx = kotlin.math.abs(seed.hashCode()) % palette.size
        return palette[idx].toSafeColorInt()
    }

    private fun hslToColor(h: Float, s: Float, l: Float): Int {
        val c = (1 - kotlin.math.abs(2 * l - 1)) * s
        val hh = h / 60f
        val x = c * (1 - kotlin.math.abs(hh % 2 - 1))
        val (r1, g1, b1) =
                when {
                    hh < 1 -> Triple(c, x, 0f)
                    hh < 2 -> Triple(x, c, 0f)
                    hh < 3 -> Triple(0f, c, x)
                    hh < 4 -> Triple(0f, x, c)
                    hh < 5 -> Triple(x, 0f, c)
                    else -> Triple(c, 0f, x)
                }
        val m = l - c / 2
        val r = ((r1 + m) * 255).toInt().coerceIn(0, 255)
        val g = ((g1 + m) * 255).toInt().coerceIn(0, 255)
        val b = ((b1 + m) * 255).toInt().coerceIn(0, 255)
        return Color.argb(255, r, g, b)
    }

    fun updateRegionClusteringOptions(options: RegionClusteringOptions?) {
        regionClusteringOptions = options
        calculateClusterMarkers()
    }

    fun calculateClusterMarkers() {
        // 移除旧聚合点
        clusterMarkers.forEach { it.marker.remove() }
        clusterMarkers.clear()

        val options = regionClusteringOptions
        if (options == null || options.enabled != true) return

        // 对每条规则生成一套聚合点
        for (rule in options.rules) {
            val grouped: Map<String, List<Marker>> =
                    dataMarkers.groupBy { marker ->
                        when (rule.by) {
                            "province" -> marker.extra?.province ?: "未知省份"
                            "city" -> marker.extra?.city ?: "未知城市"
                            "district" -> marker.extra?.district ?: "未知区"
                            else -> marker.extra?.province ?: "未知"
                        }
                    }

            for ((regionId, list) in grouped) {
                if (list.isEmpty()) continue
                val lat = list.map { it.coordinate.latitude }.average()
                val lon = list.map { it.coordinate.longitude }.average()

                val tv = TextAnnotationView(context)
                tv.setText("$regionId ${list.size}")

                val bmp = tv.toBitmap()
                val opt =
                        MarkerOptions()
                                .position(LatLng(lat, lon))
                                .icon(BitmapDescriptorFactory.fromBitmap(bmp))
                                .anchor(0.5f, 0.5f)

                val m = map.addMarker(opt)
                if (m != null) {
                    clusterMarkers.add(ClusterMarker(m, rule.by))
                }
            }
        }

        // 依据当前缩放级别切换显隐
        try {
            val currentZoom = map.cameraPosition?.zoom ?: 0f
            switchMarkersVisibility(currentZoom)
        } catch (_: Exception) {}
    }

    fun switchMarkersVisibility(zoomLevel: Float) {
        val options = regionClusteringOptions
        if (options == null || options.enabled != true) return

        // 默认全部隐藏
        clusterMarkers.forEach { it.marker.isVisible = false }
        normalMarkers.forEach { it.marker.isVisible = false }

        // 规则按 threshold 从大到小排序
        val sortedRules = options.rules.sortedByDescending { it.thresholdZoomLevel }
        var activeRule: RegionClusteringRule? = null
        for (rule in sortedRules) {
            if (zoomLevel < rule.thresholdZoomLevel.toFloat()) {
                activeRule = rule
            }
        }

        if (activeRule != null) {
            // 显示匹配规则的聚合点
            clusterMarkers.forEach { cm -> cm.marker.isVisible = cm.by == activeRule!!.by }
            // 保持 custom 样式的普通点始终可见，方便调试/演示
            normalMarkers.forEach { nm ->
                if ((nm.style ?: "") == "custom") nm.marker.isVisible = true
                else nm.marker.isVisible = false
            }
        } else {
            // 没有匹配的规则 => 显示普通点
            normalMarkers.forEach { it.marker.isVisible = true }
        }
    }
}
