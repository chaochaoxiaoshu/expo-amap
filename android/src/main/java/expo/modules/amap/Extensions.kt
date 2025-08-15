package expo.modules.amap

import android.graphics.Color
import androidx.core.graphics.toColorInt

fun String.toSafeColorInt(): Int {
    val hex = this.removePrefix("#")
    return when (hex.length) {
        6 -> {
            // #RRGGBB → #FFRRGGBB
            "#FF$hex".toColorInt()
        }
        8 -> {
            // #AARRGGBB 直接解析
            "#$hex".toColorInt()
        }
        else -> {
            // 格式不对，返回黑色
            Color.BLACK
        }
    }
}