package expo.modules.amap

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.util.AttributeSet
import android.view.View

class OutlinedCircleView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0
) : View(context, attrs, defStyleAttr) {

    var strokeColor: Int = Color.WHITE
        set(value) {
            field = value
            paint.color = value
            invalidate()
        }

    var lineWidth: Float = 2f
        set(value) {
            field = value
            paint.strokeWidth = value
            invalidate()
        }

    private val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        style = Paint.Style.STROKE
        color = strokeColor
        strokeWidth = lineWidth
    }

    init {
        // 保证背景透明
        setBackgroundColor(Color.TRANSPARENT)
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        val radius = (minOf(width, height) / 2f) - lineWidth / 2f
        val cx = width / 2f
        val cy = height / 2f
        canvas.drawCircle(cx, cy, radius, paint)
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        // 强制为正方形
        val size = minOf(MeasureSpec.getSize(widthMeasureSpec), MeasureSpec.getSize(heightMeasureSpec))
        setMeasuredDimension(size, size)
    }
}
