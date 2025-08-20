package expo.modules.amap

import android.content.Context
import com.amap.api.location.AMapLocation
import com.amap.api.location.AMapLocationClient
import com.amap.api.location.AMapLocationClientOption
import com.amap.api.location.AMapLocationListener
import expo.modules.kotlin.Promise

class LocationManager(private val context: Context) {
    private var locationClient: AMapLocationClient? = null
    private var locationOption: AMapLocationClientOption? = null

    init {
        initLocationClient()
    }

    private fun initLocationClient() {
        try {
            android.util.Log.d("LocationManager", "正在初始化高德地图定位客户端")
            locationClient = AMapLocationClient(context)
            locationOption = AMapLocationClientOption().apply {
                // 设置定位模式为高精度模式
                locationMode = AMapLocationClientOption.AMapLocationMode.High_Accuracy
                // 设置定位间隔
                interval = 2000
                // 设置是否返回地址信息
                isNeedAddress = true
                // 设置是否单次定位
                isOnceLocation = true
                // 设置是否允许模拟位置
                isMockEnable = false
                // 设置定位请求超时时间
                httpTimeOut = 30000
                // 设置是否缓存定位信息
                isLocationCacheEnable = false
            }
            locationClient?.setLocationOption(locationOption)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    fun requestLocation(promise: Promise) {
        android.util.Log.d("LocationManager", "requestLocation方法被调用")
        if (locationClient == null) {
            android.util.Log.e("LocationManager", "定位客户端为null")
            promise.reject("E_LOCATION_MANAGER_NOT_FOUND", "定位管理器未初始化")
            return
        }
        android.util.Log.d("LocationManager", "定位客户端已初始化，开始定位")

        val locationListener = AMapLocationListener { location ->
            if (location != null && location.errorCode == 0) {
                // 定位成功
                val result = mapOf(
                    "latitude" to location.latitude,
                    "longitude" to location.longitude,
                    "regeocode" to mapOf(
                        "formattedAddress" to (location.address ?: ""),
                        "country" to (location.country ?: ""),
                        "province" to (location.province ?: ""),
                        "city" to (location.city ?: ""),
                        "district" to (location.district ?: ""),
                        "citycode" to (location.cityCode ?: ""),
                        "adcode" to (location.adCode ?: ""),
                        "street" to (location.street ?: ""),
                        "number" to (location.streetNum ?: ""),
                        "poiName" to (location.poiName ?: ""),
                        "aoiName" to (location.aoiName ?: "")
                    )
                )
                promise.resolve(result)
            } else {
                // 定位失败
                val errorMessage = location?.errorInfo ?: "未知错误"
                promise.reject("E_LOCATION_FAILED", "定位失败: $errorMessage")
            }
            
            // 停止定位
            locationClient?.stopLocation()
            // 移除监听器
            locationClient?.unRegisterLocationListener(locationListener)
        }

        try {
            locationClient?.registerLocationListener(locationListener)
            locationClient?.startLocation()
        } catch (e: Exception) {
            promise.reject("E_LOCATION_FAILED", "启动定位失败: ${e.message}")
        }
    }

    fun destroy() {
        locationClient?.let { client ->
            try {
                client.onDestroy()
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
        locationClient = null
        locationOption = null
    }
}
