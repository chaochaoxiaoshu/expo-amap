package expo.modules.amap

import android.content.Context
import com.amap.api.location.AMapLocationClient
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

  override fun definition() = ModuleDefinition {
    Name("ExpoAmap")

    OnCreate {
      MapsInitializer.updatePrivacyShow(context, true, true)
      MapsInitializer.updatePrivacyAgree(context, true)
      ServiceSettings.updatePrivacyShow(context, true, true)
      ServiceSettings.updatePrivacyAgree(context, true)
      AMapLocationClient.updatePrivacyShow(context, true, true)
      AMapLocationClient.updatePrivacyAgree(context, true)

      searchManager = SearchManager(context)
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
      Events("onLoad", "onZoom", "onRegionChanged", "onTapMarker")

      Prop("region") { view, region: Region ->
        view.setRegion(region)
      }

      Prop("initialRegion") { view, region: Region ->
        if (view.regionSetted) {
          return@Prop
        }
        view.setRegion(region)
        view.regionSetted = true
      }

      Prop("limitedRegion") { view, region: Region ->
        view.setLimitedRegion(region)
      }

      Prop("mapType") { view, mapType: Int ->
        view.mapView.map?.mapType = mapType
      }

      Prop("showCompass") { view, showCompass: Boolean ->
        view.mapView.map?.uiSettings?.isCompassEnabled = showCompass
      }

      Prop("showUserLocation") { view, showUserLocation: Boolean ->
        view.mapView.map?.isMyLocationEnabled = showUserLocation
      }

      Prop("userTrackingMode") { view, userTrackingMode: Int ->
        view.setUserTrackingMode(userTrackingMode)
      }

      Prop("markers") { view, markers: Array<Marker> ->
        view.setMarkers(markers)
      }

      Prop("polylines") { view, polylines: Array<Polyline> ->
        view.setPolylines(polylines)
      }

      Prop("customStyle") { view, customStyle: CustomStyle ->
        view.setCustomStyle(customStyle)
      }

      Prop("language") { view, language: String ->
        view.setLanguage(language)
      }

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
        view: ExpoAmapView, centerCoordinate: Map<String, Double>, promise: Promise ->
        view.setCenter(centerCoordinate, promise)
      }

      AsyncFunction("setZoomLevel") { view: ExpoAmapView, zoomLevel: Int, promise: Promise ->
        view.setZoomLevel(zoomLevel, promise)
      }
    }
  }
}
