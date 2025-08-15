package expo.modules.amap

import android.content.Context
import androidx.lifecycle.LifecycleOwner
import com.amap.api.maps.AMap
import com.amap.api.maps.CameraUpdateFactory
import com.amap.api.maps.MapView
import com.amap.api.maps.model.CustomMapStyleOptions
import com.amap.api.maps.model.LatLng
import com.amap.api.maps.model.LatLngBounds
import com.amap.api.maps.model.MyLocationStyle
import expo.modules.amap.models.CustomStyle
import expo.modules.amap.models.Marker
import expo.modules.amap.models.Polyline
import expo.modules.amap.models.Region
import expo.modules.amap.models.RegionClusteringOptions
import expo.modules.kotlin.AppContext
import expo.modules.kotlin.Promise
import expo.modules.kotlin.viewevent.EventDispatcher
import expo.modules.kotlin.views.ExpoView
import androidx.lifecycle.DefaultLifecycleObserver
import com.amap.api.maps.model.CameraPosition

class ExpoAmapView(context: Context, appContext: AppContext) : ExpoView(context, appContext) {

  private var polylineManager: PolylineManager

  val mapView = MapView(context).apply {
    layoutParams = LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT)
  }

  var regionSetted = false

  private val onLoad by EventDispatcher()
  private val onZoom by EventDispatcher()
  private val onRegionChanged by EventDispatcher()

  init {
    addView(mapView)
    mapView.onCreate(null)
    polylineManager = PolylineManager(mapView.map, context)
    setListeners()

    onLoad(mapOf(
      "message" to "Map loaded successfully",
      "timestamp" to System.currentTimeMillis(),
    ))
  }

  private fun setListeners() {
    val activity = appContext.currentActivity
    if (activity is LifecycleOwner) {
      val lifecycleOwner = activity as LifecycleOwner
      lifecycleOwner.lifecycle.addObserver(object : DefaultLifecycleObserver {
        override fun onResume(owner: LifecycleOwner) {
          mapView.onResume()
        }
        override fun onPause(owner: LifecycleOwner) {
          mapView.onPause()
        }
        override fun onDestroy(owner: LifecycleOwner) {
          mapView.onDestroy()
        }
      })
    }

    mapView.map?.setOnCameraChangeListener(object: AMap.OnCameraChangeListener {
      override fun onCameraChange(p0: CameraPosition?) {
      }
      override fun onCameraChangeFinish(p0: CameraPosition?) {
        onZoom(mapOf(
          "zoomLevel" to (p0?.zoom ?: 0)
        ))
      //  onRegionChanged(Utils.mapCameraPositionToRegion(p0))
      }
    })
    //    mapView.map?.setOnMarkerClickListener { marker ->
    //
    //    }
  }

  fun setRegion(region: Region) {
    val width = mapView.width.takeIf { it > 0 } ?: 1080  // 默认宽度
    val height = mapView.height.takeIf { it > 0 } ?: 1920 // 默认高度
    val zoomLevel = Utils.regionToZoomLevel(region, width, height)
    val latLng = LatLng(region.center.latitude, region.center.longitude)
    val cameraUpdate = CameraUpdateFactory.newLatLngZoom(latLng, zoomLevel)
    mapView.map?.moveCamera(cameraUpdate)
  }

  private fun regionToLatLngBounds(region: Region): LatLngBounds {
    val centerLat = region.center.latitude
    val centerLng = region.center.longitude

    val halfLatDelta = region.span.latitudeDelta / 2
    val halfLngDelta = region.span.longitudeDelta / 2

    val southLat = centerLat - halfLatDelta
    val northLat = centerLat + halfLatDelta
    val westLng = centerLng - halfLngDelta
    val eastLng = centerLng + halfLngDelta

    val southWest = LatLng(southLat, westLng)
    val northEast = LatLng(northLat, eastLng)

    return LatLngBounds(southWest, northEast)
  }

  fun setLimitedRegion(region: Region) {
    mapView.map?.setMapStatusLimits(regionToLatLngBounds(region))
  }

  fun setUserTrackingMode(mode: Int) {
    val style = MyLocationStyle()

    when (mode) {
      0 -> style.myLocationType(MyLocationStyle.LOCATION_TYPE_SHOW)
      1 -> style.myLocationType(MyLocationStyle.LOCATION_TYPE_FOLLOW)
      2 -> style.myLocationType(MyLocationStyle.LOCATION_TYPE_LOCATION_ROTATE_NO_CENTER)
      else -> style.myLocationType(MyLocationStyle.LOCATION_TYPE_FOLLOW)
    }

    mapView.map?.myLocationStyle = style
  }

  fun setMarkers(markers: Array<Marker>) {

  }

  fun setPolylines(polylines: Array<Polyline>) {
    polylineManager.setPolyLines(polylines)
  }

  fun setCustomStyle(style: CustomStyle) {
    val amap = mapView.map ?: return

    try {
      if (style.enabled) {
        val options = CustomMapStyleOptions()

        style.styleData?.let { data ->
          options.styleData = data
        }
        style.styleExtraData?.let { extra ->
          options.styleExtraData = extra
        }

        amap.setCustomMapStyle(options)
      } else {
        amap.setCustomMapStyle(null)
      }
    } catch (e: Exception) {
      e.printStackTrace()
    }
  }

  fun setLanguage(language: String) {
    when (language.lowercase()) {
      "english" -> mapView.map?.setMapLanguage(AMap.ENGLISH)
      "chinese" -> mapView.map?.setMapLanguage(AMap.CHINESE)
      else -> mapView.map?.setMapLanguage(AMap.CHINESE)
    }
  }

  fun setRegionClusteringOptions(options: RegionClusteringOptions) {

  }

  fun setCenter(centerCoordinate: Map<String, Double>, promise: Promise) {
    try {
      val lat = centerCoordinate["latitude"] ?: 0.0
      val lng = centerCoordinate["longitude"] ?: 0.0
      val latLng = LatLng(lat, lng)
      mapView.map?.moveCamera(CameraUpdateFactory.changeLatLng(latLng))
      promise.resolve(null)
    } catch (e: Exception) {
      promise.reject("SET_CENTER_ERROR", e.message, e)
    }
  }

  fun setZoomLevel(zoomLevel: Int, promise: Promise) {
    try {
      val zoom = zoomLevel.toFloat()
      mapView.map?.moveCamera(CameraUpdateFactory.zoomTo(zoom))
      promise.resolve(null)
    } catch (e: Exception) {
      promise.reject("SET_ZOOM_ERROR", e.message, e)
    }
  }
}
