package expo.modules.amap

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import androidx.core.content.ContextCompat
import com.amap.api.location.AMapLocation
import com.amap.api.location.AMapLocationClient
import com.amap.api.location.AMapLocationClientOption
import com.amap.api.location.AMapLocationListener
import com.amap.api.maps.MapsInitializer
import com.amap.api.services.core.ServiceSettings
import expo.modules.amap.models.CustomStyle
import expo.modules.amap.models.Marker
import expo.modules.amap.models.Polyline
import expo.modules.amap.models.Region
import expo.modules.amap.models.RegionClusteringOptions
import expo.modules.amap.models.SearchDrivingRouteOptions
import expo.modules.amap.models.SearchGeocodeOptions
import expo.modules.amap.models.SearchInputTipsOptions
import expo.modules.amap.models.SearchReGeocodeOptions
import expo.modules.amap.models.SearchRidingRouteOptions
import expo.modules.amap.models.SearchTransitRouteOptions
import expo.modules.amap.models.SearchWalkingRouteOptions
import expo.modules.kotlin.Promise
import expo.modules.kotlin.exception.Exceptions
import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition

class ExpoAmapModule : Module() {
  private val context: Context
    get() = appContext.reactContext ?: throw Exceptions.ReactContextLost()

  private lateinit var searchManager: SearchManager

  private lateinit var locationClient: AMapLocationClient

  override fun definition() = ModuleDefinition {
    Name("ExpoAmap")

    OnCreate {
      android.util.Log.d("ExpoAmapModule", "开始初始化ExpoAmapModule")
      MapsInitializer.updatePrivacyShow(context, true, true)
      MapsInitializer.updatePrivacyAgree(context, true)
      ServiceSettings.updatePrivacyShow(context, true, true)
      ServiceSettings.updatePrivacyAgree(context, true)
      AMapLocationClient.updatePrivacyShow(context, true, true)
      AMapLocationClient.updatePrivacyAgree(context, true)

      searchManager = SearchManager(context)

      locationClient = AMapLocationClient(context)
      val option =
              AMapLocationClientOption().apply {
                locationMode = AMapLocationClientOption.AMapLocationMode.Hight_Accuracy
                isOnceLocation = true
                isNeedAddress = true
                isGpsFirst = false
              }
      locationClient.setLocationOption(option)
    }

    AsyncFunction("requestLocation") { promise: Promise ->
      // 权限检查：需要粗/细定位任一被授予
      val fineGranted = ContextCompat.checkSelfPermission(
          context,
          Manifest.permission.ACCESS_FINE_LOCATION
          ) == PackageManager.PERMISSION_GRANTED
      val coarseGranted =
          ContextCompat.checkSelfPermission(
              context,
              Manifest.permission.ACCESS_COARSE_LOCATION
          ) == PackageManager.PERMISSION_GRANTED
      if (!fineGranted && !coarseGranted) {
        promise.reject("LOCATION_PERMISSION_DENIED", "定位权限未授权，请先授予定位权限后重试", null)
        return@AsyncFunction
      }

      // 定义一个单次定位监听器
      val listener =
          object : AMapLocationListener {
            var called = false // 保证 promise 只调用一次

            override fun onLocationChanged(location: AMapLocation?) {
              if (called) return
              called = true

              // 停止定位并移除 listener
              locationClient.stopLocation()
              locationClient.setLocationListener(null)

              if (location != null) {
                // 返回 JS 可用的定位信息
                promise.resolve(
                        mapOf(
                                "latitude" to location.latitude,
                                "longitude" to location.longitude,
                                "regeocode" to
                                        mapOf(
                                                "formattedAddress" to location.address,
                                                "country" to location.country,
                                                "province" to location.province,
                                                "city" to location.city,
                                                "district" to location.district,
                                                "citycode" to location.cityCode,
                                                "adcode" to location.adCode,
                                                "street" to location.street,
                                                "number" to location.streetNum,
                                                "poiName" to location.poiName,
                                                "aoiName" to location.aoiName
                                        ),
                        )
                )
              } else {
                promise.reject("LOCATION_ERROR", "获取定位失败", null)
              }
            }
          }

      // 设置 listener 并启动定位
      locationClient.setLocationListener(listener)
      try {
        locationClient.startLocation()
      } catch (e: Exception) {
        locationClient.setLocationListener(null)
        promise.reject("LOCATION_EXCEPTION", "启动定位失败: ${e.message}", e)
      }
    }

    AsyncFunction("searchInputTips") { options: SearchInputTipsOptions, promise: Promise ->
      searchManager.searchInputTips(options, promise)
    }

    AsyncFunction("searchGeocode") { options: SearchGeocodeOptions, promise: Promise ->
      searchManager.searchGeocode(options, promise)
    }

    AsyncFunction("searchReGeocode") { options: SearchReGeocodeOptions, promise: Promise ->
      searchManager.searchReGeocode(options, promise)
    }

    AsyncFunction("searchDrivingRoute") { options: SearchDrivingRouteOptions, promise: Promise ->
      searchManager.searchDrivingRoute(options, promise)
    }

    AsyncFunction("searchWalkingRoute") { options: SearchWalkingRouteOptions, promise: Promise ->
      searchManager.searchWalkingRoute(options, promise)
    }

    AsyncFunction("searchRidingRoute") { options: SearchRidingRouteOptions, promise: Promise ->
      searchManager.searchRidingRoute(options, promise)
    }

    AsyncFunction("searchTransitRoute") { options: SearchTransitRouteOptions, promise: Promise ->
      searchManager.searchTransitRoute(options, promise)
    }

    View(ExpoAmapView::class) {
      Events("onLoad", "onZoom", "onRegionChanged", "onTapMarker", "onTapPolyline")

      Prop("initialRegion") { view, region: Region -> view.setInitialRegion(region) }

      Prop("limitedRegion") { view, region: Region -> view.setLimitedRegion(region) }

      Prop("mapType") { view, mapType: Int -> view.mapView.map?.mapType = mapType }

      Prop("showCompass") { view, showCompass: Boolean ->
        view.mapView.map?.uiSettings?.isCompassEnabled = showCompass
      }

      Prop("showUserLocation") { view, showUserLocation: Boolean ->
        view.mapView.map?.isMyLocationEnabled = showUserLocation
      }

      Prop("userTrackingMode") { view, userTrackingMode: Int ->
        view.setUserTrackingMode(userTrackingMode)
      }

      Prop("markers") { view, markers: Array<Marker> -> view.setMarkers(markers) }

      Prop("polylines") { view, polylines: Array<Polyline> -> view.setPolylines(polylines) }

      Prop("customStyle") { view, customStyle: CustomStyle -> view.setCustomStyle(customStyle) }

      Prop("language") { view, language: String -> view.setLanguage(language) }

      Prop("minZoomLevel") { view, minZoomLevel: Double ->
        view.mapView.map?.minZoomLevel = minZoomLevel.toFloat()
      }

      Prop("maxZoomLevel") { view, maxZoomLevel: Double ->
        view.mapView.map?.maxZoomLevel = maxZoomLevel.toFloat()
      }

      Prop("regionClusteringOptions") { view, options: RegionClusteringOptions ->
        view.setRegionClusteringOptions(options)
      }

      AsyncFunction("setCenter") {
              view: ExpoAmapView,
              centerCoordinate: Map<String, Double>,
              promise: Promise ->
        view.setCenter(centerCoordinate, promise)
      }

      AsyncFunction("setZoomLevel") { view: ExpoAmapView, zoomLevel: Int, promise: Promise ->
        view.setZoomLevel(zoomLevel, promise)
      }
    }
  }
}
