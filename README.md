# Expo Amap

> 🚀 支持 iOS 和 Android 的高德地图 Expo 模块

`expo-amap` 让你在 Expo app 中使用高德地图 iOS 与 Android SDK，集成了 `AMapFoundation`, `AMap3DMap`, `AMapSearch` 与 `AMapLocation`。

# 特性

- ⚛️ 声明式 API
- 🔵 一流的 TypeScript 支持
- 📦 基于 Expo Modules API，支持新架构

# 安装

```bash
npx expo install expo-amap
```

# 配置

在你的 `app.json` 或 `app.config.(ts/js)` 中添加以下配置：

```json
{
  "expo": {
    "plugins": [
      [
        "expo-amap",
        {
          "apiKey": {
            "ios": "YOUR_AMAP_API_KEY",
            "android": "YOUR_AMAP_API_KEY"
          }
        }
      ]
    ]
  }
}
```

然后执行 `npx expo prebuild` 生成原生项目。

## 权限配置

### iOS

在 `ios/Info.plist` 中添加以下权限描述：

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>需要定位权限来获取您的位置信息</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>需要定位权限来获取您的位置信息</string>
```

### Android

在 `android/app/src/main/AndroidManifest.xml` 中确保有以下权限：

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
```

# 使用方法

如果你正在使用 iOS 模拟器或 Android 模拟器，请确保 [已启用位置功能](https://docs.expo.dev/versions/latest/sdk/location/#enable-emulator-location)。

## 地图显示

```tsx
import { useRef } from 'react'
import ExpoAmapModule, { MapView, type MapViewRef } from 'expo-amap'

export default function App() {
  const mapViewRef = useRef<MapViewRef>(null)

  return (
    <MapView ref={mapViewRef} style={{ flex: 1 }} />
  )
}
```

## 获取定位

```tsx
import ExpoAmapModule from 'expo-amap'

async function getLocation() {
  try {
    const location = await ExpoAmapModule.requestLocation()
    console.log('定位成功:', location)
    console.log('纬度:', location.latitude)
    console.log('经度:', location.longitude)
    console.log('地址:', location.regeocode.formattedAddress)
    console.log('城市:', location.regeocode.city)
  } catch (error) {
    console.error('定位失败:', error)
  }
}
```

定位返回的数据结构：

```typescript
interface RequestLocationResult {
  latitude: number        // 纬度
  longitude: number       // 经度
  regeocode: {
    formattedAddress?: string  // 格式化地址
    country?: string           // 国家
    province?: string          // 省份
    city?: string             // 城市
    district?: string         // 区县
    citycode?: string         // 城市编码
    adcode?: string           // 区县编码
    street?: string           // 街道
    number?: string           // 门牌号
    poiName?: string          // 兴趣点名称
    aoiName?: string          // 兴趣点名称
  }
}
```