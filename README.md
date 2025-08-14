# Expo Amap

`expo-amap` 让你在 Expo app 中使用高德地图 iOS 与 Android SDK，集成了 `AMapFoundation`, `AMap3DMap`, `AMapSearch` 与 `AMapLocation`。

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

# 使用方法

如果你正在使用 iOS 模拟器或 Android 模拟器，请确保 [已启用位置功能](https://docs.expo.dev/versions/latest/sdk/location/#enable-emulator-location)。

```tsx
import { useRef } from 'react'
import ExpoAmapModule, {
  MapView,
  Marker,
  Polyline,
  type MapViewRef
} from 'expo-amap'

export default function App() {
  const mapViewRef = useRef<MapViewRef>(null)

  return (
    <MapView ref={mapViewRef} style={{ flex: 1 }} />
  )
}
```