import { useRef } from 'react'
import { View, Button } from 'react-native'
import ExpoAmapModule, {
  MapView,
  Marker,
  Polyline,
  type MapViewRef
} from 'expo-amap'

async function getLocation() {
  const location = await ExpoAmapModule.requestLocation()
  console.log('location', location)
}

async function handleSearchGeocode() {
  try {
    const result = await ExpoAmapModule.searchGeocode({
      address: '上海市浦东新区世纪大道 2000 号'
    })
    console.log('geocode result', result)
  } catch (error) {
    console.log((error as Error).message)
  }
}

async function handleSearchReGeocode() {
  try {
    const result = await ExpoAmapModule.searchReGeocode({
      location: { latitude: 31.230545, longitude: 121.473724 },
      radius: 1000,
      poitype: 'bank',
      mode: 'all'
    })
    console.log('regeocode result', result)
  } catch (error) {
    console.log((error as Error).message)
  }
}

async function handleSearchInputTips() {
  try {
    const result = await ExpoAmapModule.searchInputTips({
      keywords: '方圆大厦',
      city: '024'
    })
    console.log('input tips result', result)
  } catch (error) {
    console.log((error as Error).message)
  }
}

async function handleSearchDrivingRoute() {
  try {
    const result = await ExpoAmapModule.searchDrivingRoute({
      origin: { latitude: 31.230545, longitude: 121.473724 },
      destination: { latitude: 39.900896, longitude: 116.401049 },
      showFieldType: 'polyline'
    })
    console.log('🚗 驾车路线规划结果:', result)
  } catch (error) {
    console.log((error as Error).message)
  }
}

async function handleSearchWalkingRoute() {
  try {
    const result = await ExpoAmapModule.searchWalkingRoute({
      origin: { latitude: 31.230545, longitude: 121.473724 },
      destination: { latitude: 31.223257, longitude: 121.471266 },
      showFieldType: 'polyline'
    })
    console.log('🚶 步行路线规划结果:', result)
  } catch (error) {
    console.log((error as Error).message)
  }
}

async function handleSearchRidingRoute() {
  try {
    const result = await ExpoAmapModule.searchRidingRoute({
      origin: { latitude: 31.230545, longitude: 121.473724 },
      destination: { latitude: 31.223257, longitude: 121.471266 },
      showFieldType: 'polyline'
    })
    console.log('🚲 骑行路线规划结果:', result)
  } catch (error) {
    console.log((error as Error).message)
  }
}

async function handleSearchTransitRoute() {
  try {
    const result = await ExpoAmapModule.searchTransitRoute({
      origin: { latitude: 31.230545, longitude: 121.473724 },
      destination: { latitude: 31.223257, longitude: 121.471266 },
      strategy: 0,
      city: '021',
      destinationCity: '021',
      showFieldType: 'polyline'
    })
    console.log('🚌 公交路线规划结果:', result)
  } catch (error) {
    console.log((error as Error).message)
  }
}

export default function App() {
  const mapViewRef = useRef<MapViewRef>(null)

  return (
    <View style={{ position: 'relative', flex: 1 }}>
      <MapView
        ref={mapViewRef}
        style={{ flex: 1 }}
        mapType={0}
        showCompass={false}
        showUserLocation={true}
        userTrackingMode={0}
        onLoad={(event) => {
          console.log('🗺️ 地图加载成功:', event.nativeEvent)
        }}
        onZoom={(event) => {
          console.log('🗺️ 地图缩放:', event.nativeEvent)
        }}
        onRegionChanged={(event) => {
          console.log('🗺️ 地图区域变化:', event.nativeEvent)
        }}
        onTapMarker={(event) => {
          console.log('🗺️ 地图点击标记:', event.nativeEvent)
        }}
      >
        <Marker
          id='marker1'
          coordinate={{ latitude: 31.230545, longitude: 121.473724 }}
          title='闪数科技'
          subtitle='闪数科技'
          canShowCallout
          image={{
            url: 'https://qiniu.zdjt.com/shop/2025-07-24/e84b870f7c916a381afe91c974243cb5.jpg',
            size: {
              width: 100,
              height: 30
            }
          }}
          centerOffset={{
            x: 0,
            y: -15
          }}
          textStyle={{
            fontSize: 24,
            color: '#FF0000'
          }}
        />
        <Marker
          id='marker2'
          coordinate={{ latitude: 31.223257, longitude: 121.471266 }}
          title='闪数科技'
          subtitle='闪数科技'
          canAdjustPosition
          canShowCallout
        />
        <Marker
          id='marker3'
          coordinate={{ latitude: 31.227265, longitude: 121.479399 }}
          title='飞书'
          subtitle='闪数科技'
          canShowCallout
          image={{
            url: 'https://qiniu.zdjt.com/shop/2025-07-24/e84b870f7c916a381afe91c974243cb5.jpg',
            size: {
              width: 100,
              height: 30
            }
          }}
          centerOffset={{
            x: 0,
            y: -15
          }}
          textStyle={{
            fontSize: 24,
            color: '#FF0000'
          }}
        />
        <Polyline
          coordinates={[
            { latitude: 31.230545, longitude: 121.473724 },
            { latitude: 31.228051, longitude: 121.467568 }
          ]}
          style={{
            strokeColor: '#FF0000',
            lineWidth: 4,
            lineDashType: 2
          }}
        />
        <Polyline
          coordinates={[
            { latitude: 31.228051, longitude: 121.467568 },
            { latitude: 31.223257, longitude: 121.471266 }
          ]}
          style={{
            strokeColor: '#00FF00',
            lineWidth: 6,
            lineDashType: 1
          }}
        />
        <Polyline
          coordinates={[
            { latitude: 31.223257, longitude: 121.471266 },
            { latitude: 31.227265, longitude: 121.479399 }
          ]}
          style={{
            fillColor: '#FF0000',
            strokeColor: '#00FF00',
            lineWidth: 6,
            lineDashType: 1
          }}
        />
      </MapView>
      <View
        style={{
          position: 'absolute',
          width: '100%',
          bottom: 0,
          left: 0,
          right: 0,
          flexDirection: 'row',
          justifyContent: 'center',
          flexWrap: 'wrap',
          paddingVertical: 32,
          paddingHorizontal: 20,
          backgroundColor: 'rgba(255, 255, 255, 0.8)'
        }}
      >
        <Button title='获取定位' onPress={getLocation} />
        <Button title='地理编码' onPress={handleSearchGeocode} />
        <Button title='逆地理编码' onPress={handleSearchReGeocode} />
        <Button title='关键字搜索' onPress={handleSearchInputTips} />
        <Button title='规划驾车路线' onPress={handleSearchDrivingRoute} />
        <Button title='规划步行路线' onPress={handleSearchWalkingRoute} />
        <Button title='规划骑行路线' onPress={handleSearchRidingRoute} />
        <Button title='规划公交路线' onPress={handleSearchTransitRoute} />
      </View>
    </View>
  )
}
