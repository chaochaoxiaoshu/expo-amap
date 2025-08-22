package expo.modules.amap

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.util.AttributeSet
import android.util.TypedValue
import android.view.Gravity
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.TextView
import expo.modules.amap.models.Point
import expo.modules.amap.models.Size
import expo.modules.amap.models.TextStyle

class TextAnnotationView @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null) :
        FrameLayout(context, attrs) {

  private val backgroundImageView = ImageView(context)
  private val textLabelView = TextView(context)

  private var desiredImageWidthPx: Int? = null
  private var desiredImageHeightPx: Int? = null

  var textStyle: TextStyle? = null
    set(value) {
      field = value
      applyTextStyle()
    }

  var textOffset: Point? = null
    set(value) {
      field = value
      positionTextLabel()
    }

  init {
    layoutParams = LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT)

    addView(backgroundImageView, LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT))

    textLabelView.setTextColor(Color.WHITE)
    textLabelView.setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f)
    textLabelView.typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
    textLabelView.paint.isAntiAlias = true
    textLabelView.includeFontPadding = false
    textLabelView.setPadding(dp(6), dp(4), dp(6), dp(4))
    textLabelView.background =
            GradientDrawable().apply {
              shape = GradientDrawable.RECTANGLE
              cornerRadius = dpF(6f)
              setColor("#5981D8".toSafeColorInt())
            }
    textLabelView.gravity = Gravity.CENTER
    textLabelView.isSingleLine = true

    val labelParams = LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT)
    labelParams.gravity = Gravity.CENTER
    addView(textLabelView, labelParams)
  }

  fun setText(text: String?) {
    if (text.isNullOrEmpty()) {
      textLabelView.text = null
      textLabelView.visibility = GONE
    } else {
      textLabelView.visibility = VISIBLE
      textLabelView.text = text
      applyTextStyle()
      bringChildToFront(textLabelView)
      textLabelView.measure(
              MeasureSpec.makeMeasureSpec(0, MeasureSpec.UNSPECIFIED),
              MeasureSpec.makeMeasureSpec(0, MeasureSpec.UNSPECIFIED)
      )
    }
    requestLayout()
    invalidate()
  }

  fun setImage(bitmap: Bitmap?, size: Size?) {
    if (bitmap != null) {
      backgroundImageView.setImageBitmap(bitmap)
      val w = (size?.width?.toFloat() ?: bitmap.width.toFloat())
      val h = (size?.height?.toFloat() ?: bitmap.height.toFloat())
      desiredImageWidthPx = dpF(w).toInt()
      desiredImageHeightPx = dpF(h).toInt()
      backgroundImageView.layoutParams = LayoutParams(desiredImageWidthPx!!, desiredImageHeightPx!!)
    } else {
      backgroundImageView.setImageDrawable(null)
      desiredImageWidthPx = null
      desiredImageHeightPx = null
    }
    requestLayout()
  }

  private fun applyTextStyle() {
    val style = textStyle
    if (style == null) {
      textLabelView.setTextColor(Color.WHITE)
      textLabelView.setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f)
      textLabelView.typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
      textLabelView.setPadding(dp(6), dp(4), dp(6), dp(4))
      (textLabelView.background as? GradientDrawable)?.apply {
        cornerRadius = dpF(6f)
        setColor("#5981D8".toSafeColorInt())
      }
      return
    }

    style.color?.let { textLabelView.setTextColor(it.toSafeColorInt()) }
    style.fontSize?.let { textLabelView.setTextSize(TypedValue.COMPLEX_UNIT_SP, it.toFloat()) }
    style.fontWeight?.let {
      val tf =
              when (it.lowercase()) {
                "bold", "700", "800", "900" -> Typeface.BOLD
                "600", "500", "medium" -> Typeface.BOLD
                else -> Typeface.NORMAL
              }
      textLabelView.typeface = Typeface.create(Typeface.DEFAULT, tf)
    }
    style.numberOfLines?.let { n ->
      if (n <= 1) textLabelView.isSingleLine = true else textLabelView.maxLines = n
    }
    style.padding?.let { p ->
      textLabelView.setPadding(
              dpF(p.x.toFloat()).toInt(),
              dpF(p.y.toFloat()).toInt(),
              dpF(p.x.toFloat()).toInt(),
              dpF(p.y.toFloat()).toInt()
      )
    }
    style.backgroundColor?.let { hex ->
      (textLabelView.background as? GradientDrawable)?.apply { setColor(hex.toSafeColorInt()) }
    }
    requestLayout()
  }

  private fun positionTextLabel() {
    val offset = textOffset
    val lp = textLabelView.layoutParams as LayoutParams
    lp.gravity = Gravity.CENTER
    textLabelView.layoutParams = lp
    if (offset != null) {
      textLabelView.translationX = dpF(offset.x.toFloat())
      textLabelView.translationY = dpF(offset.y.toFloat())
    } else {
      textLabelView.translationX = 0f
      textLabelView.translationY = 0f
    }
  }

  override fun onLayout(changed: Boolean, left: Int, top: Int, right: Int, bottom: Int) {
    super.onLayout(changed, left, top, right, bottom)
    // 确保文本在父视图布局后仍位于中心并应用偏移
    positionTextLabel()
  }

  fun toBitmap(): Bitmap {
    // 直接在位图上绘制（更稳定）
    val text = textLabelView.text?.toString() ?: ""
    val p = textLabelView.paint
    p.isAntiAlias = true
    p.textAlign = android.graphics.Paint.Align.CENTER

    val padL = textLabelView.paddingLeft
    val padR = textLabelView.paddingRight
    val padT = textLabelView.paddingTop
    val padB = textLabelView.paddingBottom

    val textW = if (text.isEmpty()) 0f else p.measureText(text)
    val fm = p.fontMetrics
    val textH = if (text.isEmpty()) 0f else (fm.bottom - fm.top)

    val bubbleW = (textW + padL + padR).toInt()
    val bubbleH = (textH + padT + padB).toInt()

    val imgW = desiredImageWidthPx ?: 0
    val imgH = desiredImageHeightPx ?: 0

    val totalW = maxOf(imgW, bubbleW, 1)
    val totalH = maxOf(imgH, bubbleH, 1)

    val bitmap = Bitmap.createBitmap(totalW, totalH, Bitmap.Config.ARGB_8888)
    val canvas = Canvas(bitmap)

    // 画图片（如有）
    (backgroundImageView.drawable as? android.graphics.drawable.BitmapDrawable)?.bitmap?.let { src
      ->
      val dw = if (imgW > 0) imgW else src.width
      val dh = if (imgH > 0) imgH else src.height
      val left = (totalW - dw) / 2
      val top = (totalH - dh) / 2
      val dst = android.graphics.Rect(left, top, left + dw, top + dh)
      canvas.drawBitmap(src, null, dst, null)
    }

    // 画文本气泡（如有文本）
    if (text.isNotEmpty()) {
      val bgColor = (textStyle?.backgroundColor ?: "#5981D8").toSafeColorInt()
      val textColor = textStyle?.color?.toSafeColorInt() ?: Color.WHITE

      val rect =
              android.graphics.RectF(
                      (totalW - bubbleW) / 2f,
                      (totalH - bubbleH) / 2f,
                      (totalW + bubbleW) / 2f,
                      (totalH + bubbleH) / 2f
              )
      val bgPaint =
              android.graphics.Paint(android.graphics.Paint.ANTI_ALIAS_FLAG).apply {
                style = android.graphics.Paint.Style.FILL
                color = bgColor
              }
      val radius = dpF(6f)
      canvas.drawRoundRect(rect, radius, radius, bgPaint)

      p.color = textColor
      val centerX = totalW / 2f
      val baseline = totalH / 2f - (fm.ascent + fm.descent) / 2f
      canvas.drawText(text, centerX, baseline, p)
    }

    return bitmap
  }

  private fun measureLabelWidth(): Int {
    if (textLabelView.visibility != VISIBLE) return 0
    textLabelView.measure(
            MeasureSpec.makeMeasureSpec(0, MeasureSpec.UNSPECIFIED),
            MeasureSpec.makeMeasureSpec(0, MeasureSpec.UNSPECIFIED)
    )
    var w = textLabelView.measuredWidth
    if (w == 0) {
      val text = textLabelView.text?.toString() ?: ""
      w =
              (textLabelView.paint.measureText(text) +
                              textLabelView.paddingLeft +
                              textLabelView.paddingRight)
                      .toInt()
    }
    return w
  }

  private fun measureLabelHeight(): Int {
    if (textLabelView.visibility != VISIBLE) return 0
    textLabelView.measure(
            MeasureSpec.makeMeasureSpec(0, MeasureSpec.UNSPECIFIED),
            MeasureSpec.makeMeasureSpec(0, MeasureSpec.UNSPECIFIED)
    )
    var h = textLabelView.measuredHeight
    if (h == 0) {
      val fm = textLabelView.paint.fontMetrics
      h = ((fm.bottom - fm.top) + textLabelView.paddingTop + textLabelView.paddingBottom).toInt()
    }
    return h
  }

  private fun dp(value: Int): Int = (value * context.resources.displayMetrics.density).toInt()
  private fun dpF(value: Float): Float = value * context.resources.displayMetrics.density
}
