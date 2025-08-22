package expo.modules.amap

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.util.AttributeSet
import android.util.TypedValue
import android.view.Gravity
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView

class TeardropMarkerView @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null) :
        FrameLayout(context, attrs) {

    private val teardrop = TeardropView(context)
    private val textLabel = TextView(context)
    private val circleView = OutlinedCircleView(context)
    private val infoView =
            LinearLayout(context).apply {
                orientation = LinearLayout.HORIZONTAL
                visibility = GONE
                val padH = dp(8)
                val padV = dp(4)
                setPadding(padH, padV, padH, padV)
                background =
                        GradientDrawable().apply {
                            setColor(Color.WHITE)
                            cornerRadius = dpF(12f)
                            setStroke(1, Color.LTGRAY)
                        }
                elevation = 4f
            }
    private val infoIcon = ImageView(context)
    private val infoLabel = TextView(context)

    var label: String? = null
        set(value) {
            field = value
            updateContent()
        }

    var infoText: String? = null
        set(value) {
            field = value
            updateInfoView()
        }

    var teardropFillColor: Int
        get() = teardrop.fillColor
        set(value) {
            teardrop.fillColor = value
            teardrop.invalidate()
        }

    init {
        val w = dp(20)
        val h = dp(24)
        layoutParams = LayoutParams(w, h)

        // 背景水滴（固定 20x24，底部居中）
        val dropParams = LayoutParams(w, h, Gravity.BOTTOM or Gravity.CENTER_HORIZONTAL)
        addView(teardrop, dropParams)

        // 文本（位于水滴圆形区域，大小 20x20，距底部 4dp）
        textLabel.apply {
            setTextColor(Color.WHITE)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f)
            gravity = Gravity.CENTER
            visibility = GONE
        }
        val labelParams = LayoutParams(w, w, Gravity.BOTTOM or Gravity.CENTER_HORIZONTAL)
        labelParams.bottomMargin = dp(4)
        addView(textLabel, labelParams)

        // 圆圈（与文本同位）
        circleView.visibility = GONE
        circleView.lineWidth = dpF(2f)
        val circleSize = dp(12)
        val circleParams =
                LayoutParams(circleSize, circleSize, Gravity.BOTTOM or Gravity.CENTER_HORIZONTAL)
        circleParams.bottomMargin = dp(8)
        addView(circleView, circleParams)

        // infoView（水平胶囊，居上居中）
        infoIcon.setImageResource(android.R.drawable.ic_lock_idle_alarm)
        infoIcon.setColorFilter(Color.DKGRAY)
        val iconSize = dp(14)
        infoView.gravity = Gravity.CENTER_VERTICAL
        infoView.addView(infoIcon, LayoutParams(iconSize, iconSize))

        infoLabel.setTextColor(Color.BLACK)
        infoLabel.setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f)
        infoLabel.setSingleLine(true)
        val labelLp = LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT)
        labelLp.marginStart = dp(4)
        infoView.addView(infoLabel, labelLp)

        val infoParams = LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT)
        infoParams.gravity = Gravity.TOP or Gravity.CENTER_HORIZONTAL
        addView(infoView, infoParams)

        // 默认内容刷新，确保无 label 时显示圆圈
        updateContent()
        updateInfoView()
    }

    private fun updateContent() {
        if (!label.isNullOrEmpty()) {
            textLabel.text = label
            textLabel.visibility = VISIBLE
            circleView.visibility = GONE
        } else {
            textLabel.visibility = GONE
            circleView.visibility = VISIBLE
        }
    }

    private fun updateInfoView() {
        if (!infoText.isNullOrEmpty()) {
            infoLabel.text = infoText
            infoView.visibility = VISIBLE
        } else {
            infoView.visibility = GONE
        }
        requestLayout()
    }

    /** 转换为 Bitmap 用于 Marker */
    fun toBitmap(): Bitmap {
        val dropW = dp(20)
        val dropH = dp(24)
        val gap = dp(6)

        // 预测量 infoView 尺寸
        var infoW = 0
        var infoH = 0
        if (!infoText.isNullOrEmpty()) {
            infoView.measure(
                    MeasureSpec.makeMeasureSpec(0, MeasureSpec.UNSPECIFIED),
                    MeasureSpec.makeMeasureSpec(0, MeasureSpec.UNSPECIFIED)
            )
            infoW = infoView.measuredWidth
            infoH = infoView.measuredHeight
        }

        val totalW = maxOf(dropW, infoW)
        val totalH = if (infoH > 0) dropH + gap + infoH else dropH

        // 以最终尺寸测量并布局自身
        measure(
                MeasureSpec.makeMeasureSpec(totalW, MeasureSpec.EXACTLY),
                MeasureSpec.makeMeasureSpec(totalH, MeasureSpec.EXACTLY)
        )
        layout(0, 0, totalW, totalH)

        // 生成位图
        val bitmap = Bitmap.createBitmap(totalW, totalH, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        draw(canvas)
        return bitmap
    }

    private fun dp(value: Int): Int = (value * context.resources.displayMetrics.density).toInt()
    private fun dpF(value: Float): Float = value * context.resources.displayMetrics.density
}
