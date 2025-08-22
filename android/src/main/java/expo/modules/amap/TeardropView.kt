package expo.modules.amap

import android.content.Context
import android.graphics.*
import android.util.AttributeSet
import android.view.View

class TeardropView
@JvmOverloads
constructor(context: Context, attrs: AttributeSet? = null, defStyleAttr: Int = 0) :
        View(context, attrs, defStyleAttr) {

    var fillColor: Int = Color.rgb(217, 217, 217)
        set(value) {
            field = value
            invalidate() // 重新绘制
        }

    private val paint =
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                style = Paint.Style.FILL
                color = fillColor
            }

    private val path = Path()

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)

        path.reset()

        val width = width.toFloat()
        val height = height.toFloat()

        val svgWidth = 20f
        val svgHeight = 24f

        val scale = minOf(width / svgWidth, height / svgHeight)
        val dx = (width - svgWidth * scale) / 2f
        val dy = (height - svgHeight * scale) / 2f

        // 构建路径（原始 20x24），再整体缩放和平移，保证居中不变形
        path.moveTo(20f, 10.0401f)
        path.cubicTo(20f, 17.3295f, 10f, 24f, 10f, 24f)
        path.cubicTo(10f, 24f, 0f, 17.3295f, 0f, 10.0401f)
        path.cubicTo(0f, 4.49511f, 4.47715f, 0f, 10f, 0f)
        path.cubicTo(15.5228f, 0f, 20f, 4.49511f, 20f, 10.0401f)
        path.close()

        path.transform(
                Matrix().apply {
                    setScale(scale, scale)
                    postTranslate(dx, dy)
                }
        )

        paint.color = fillColor
        canvas.drawPath(path, paint)
    }
}
