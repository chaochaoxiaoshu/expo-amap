import { useRef } from 'react'
import { View, Button } from 'react-native'
import ExpoAmapModule, {
  MapView,
  Marker,
  OnTapMarkerEventPayload,
  Polyline,
  type MapViewRef
} from 'expo-amap'

const examplePoints = [
  {
    id: '1',
    city: '太原市',
    district: '小店区',
    coordinate: { latitude: 37.824951, longitude: 112.566923 }
  },
  {
    id: '2',
    city: '太原市',
    district: '小店区',
    coordinate: { latitude: 37.816595, longitude: 112.562669 }
  },
  {
    id: '3',
    city: '太原市',
    district: '小店区',
    coordinate: { latitude: 37.809569, longitude: 112.572245 }
  },
  {
    id: '4',
    city: '太原市',
    district: '万柏林区',
    coordinate: { latitude: 37.862116, longitude: 112.522754 }
  },
  {
    id: '5',
    city: '太原市',
    district: '万柏林区',
    coordinate: { latitude: 37.867722, longitude: 112.507784 }
  },
  {
    id: '6',
    city: '太原市',
    district: '万柏林区',
    coordinate: { latitude: 37.876592, longitude: 112.492825 }
  }
] satisfies {
  id: string
  city: string
  district: string
  coordinate: { latitude: number; longitude: number }
}[]

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

  const handleTapMarker = (event: { nativeEvent: OnTapMarkerEventPayload }) => {
    mapViewRef.current?.setCenter(event.nativeEvent.coordinate)
  }

  return (
    <View style={{ position: 'relative', flex: 1 }}>
      <MapView
        ref={mapViewRef}
        style={{ flex: 1 }}
        initialRegion={{
          center: { latitude: 37.842568, longitude: 112.539263 },
          span: {
            latitudeDelta: 0.2,
            longitudeDelta: 0.2
          }
        }}
        showCompass={false}
        showUserLocation={true}
        userTrackingMode={0}
        regionClusteringOptions={{
          enabled: true,
          rules: [
            { by: 'district', thresholdZoomLevel: 12 },
            { by: 'city', thresholdZoomLevel: 10 },
            { by: 'province', thresholdZoomLevel: 8 }
          ]
        }}
        onTapMarker={handleTapMarker}
      >
        {examplePoints.map((point) => (
          <Marker
            key={point.id}
            id={point.id}
            coordinate={{
              latitude: point.coordinate.latitude,
              longitude: point.coordinate.longitude
            }}
            canShowCallout
            style='custom'
            title='闪数123'
            extra={{
              province: '山西省',
              city: point.city,
              district: point.district
            }}
          />
        ))}
        <Polyline
          coordinates={[
            { latitude: 37.83844, longitude: 112.531737 },
            { latitude: 37.818767, longitude: 112.528263 },
            { latitude: 37.817663, longitude: 112.538917 }
          ]}
          style={{
            strokeColor: '#FF0000',
            lineWidth: 10,
            lineDashType: 2
          }}
        />
        <Polyline
          coordinates={[
            { latitude: 37.817663, longitude: 112.538917 },
            { latitude: 37.817502, longitude: 112.56487 }
          ]}
          style={{
            strokeColor: '#00FF00',
            lineWidth: 6,
            lineDashType: 1
          }}
        />
        <Polyline
          coordinates={[
            { latitude: 37.817502, longitude: 112.56487 },
            { latitude: 37.838878, longitude: 112.568771 }
          ]}
          style={{
            fillColor: '#FF0000',
            strokeColor: '#00FF00',
            lineWidth: 6,
            lineDashType: 0
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
