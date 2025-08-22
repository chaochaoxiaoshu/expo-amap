import { useRef } from 'react'
import { View, Button, PermissionsAndroid, Platform } from 'react-native'
import ExpoAmapModule, {
  MapView,
  Marker,
  OnTapMarkerEventPayload,
  Polyline,
  type MapViewRef
} from 'expo-amap'

const path =
  '112.588854,37.824514;112.588902,37.823885;112.588902,37.823885;112.588902,37.823793;112.588902,37.823793;112.588889,37.823763;112.588876,37.823451;112.588872,37.823446;112.58809,37.823503;112.58809,37.823503;112.587891,37.823511;112.587535,37.823537;112.587535,37.823537;112.587435,37.82355;112.587435,37.82355;112.587283,37.823559;112.587283,37.823559;112.587066,37.823576;112.587066,37.823576;112.586766,37.823594;112.586766,37.823594;112.586523,37.823607;112.586523,37.823607;112.585929,37.823646;112.585929,37.823646;112.585069,37.823694;112.585069,37.823694;112.584518,37.823733;112.584518,37.823733;112.584431,37.823737;112.584431,37.823737;112.583746,37.823785;112.583746,37.823785;112.583685,37.823789;112.583685,37.823789;112.583069,37.823828;112.583069,37.823828;112.582695,37.823854;112.582695,37.823854;112.582444,37.823876;112.582444,37.823876;112.582261,37.823924;112.581602,37.823971;112.581602,37.823971;112.580226,37.824058;112.580226,37.824058;112.579991,37.824076;112.579991,37.824076;112.579644,37.82408;112.57878,37.824036;112.57878,37.824036;112.578555,37.824023;112.578555,37.824023;112.577422,37.823971;112.577422,37.823971;112.577044,37.82395;112.576697,37.823863;112.576697,37.823863;112.575447,37.823806;112.575447,37.823806;112.574657,37.823767;112.574657,37.823767;112.573841,37.823724;112.573841,37.823724;112.573763,37.823724;112.573763,37.823724;112.573142,37.823694;112.573142,37.823694;112.57145,37.823611;112.57145,37.823611;112.570243,37.823568;112.570243,37.823568;112.569822,37.823568;112.569822,37.823568;112.56944,37.823568;112.56944,37.823568;112.569306,37.823563;112.569306,37.823563;112.568034,37.823529;112.568034,37.823529;112.567617,37.823516;112.567617,37.823516;112.567426,37.823511;112.567426,37.823511;112.567309,37.823507;112.567309,37.823507;112.56638,37.823485;112.56638,37.823485;112.56592,37.823485;112.56513,37.823464;112.56513,37.823464;112.564905,37.823455;112.564905,37.823455;112.564813,37.823455;112.564813,37.823455;112.564514,37.823503;112.563741,37.82349;112.563741,37.82349;112.563038,37.823468;112.56276,37.823416;112.56276,37.823416;112.562687,37.823416;112.562687,37.823416;112.562617,37.823416;112.562617,37.823416;112.562526,37.823407;112.562526,37.823407;112.562279,37.823403;112.562279,37.823403;112.561949,37.823403;112.561949,37.823403;112.561736,37.823398;112.561736,37.823398;112.561246,37.823381;112.561246,37.823381;112.560946,37.823377;112.560946,37.823377;112.560373,37.823372;112.560373,37.823372;112.559831,37.823359;112.559831,37.823359;112.558268,37.823333;112.558268,37.823333;112.558025,37.823325;112.558025,37.823325;112.557799,37.823325;112.557799,37.823325;112.55697,37.823312;112.55697,37.823312;112.556228,37.823294;112.556228,37.823294;112.555955,37.82329;112.555955,37.82329;112.555625,37.823286;112.555625,37.823286;112.555395,37.823281;112.555395,37.823281;112.554774,37.823273;112.55477,37.823268;112.554549,37.823303;112.554549,37.823303;112.554032,37.82329;112.554032,37.82329;112.553867,37.82329;112.553867,37.82329;112.552856,37.82329;112.552856,37.82329;112.5526,37.823299;112.5526,37.823299;112.552183,37.823325;112.551875,37.823325;112.551875,37.823325;112.550638,37.823316;112.550638,37.823316;112.549596,37.823212;112.549596,37.823212;112.548815,37.823199;112.548811,37.823194;112.548806,37.823142;112.548806,37.823142;112.548685,37.822622;112.548685,37.822622;112.54862,37.822348;112.54862,37.822348;112.548559,37.822105;112.548559,37.822105;112.548438,37.821632;112.548438,37.821632;112.548342,37.821263;112.548342,37.821263;112.548251,37.820903;112.548251,37.820903;112.548186,37.820647;112.548186,37.820647;112.548099,37.820326;112.548099,37.820326;112.54803,37.820056;112.54803,37.820056;112.547938,37.819709;112.547938,37.819709;112.547899,37.819553;112.547899,37.819553;112.547743,37.81895;112.547743,37.81895;112.547734,37.818919;112.547734,37.818919;112.547656,37.818555;112.547656,37.818555;112.547487,37.817973;112.547487,37.817973;112.547431,37.817778;112.547426,37.817773;112.54701,37.817773;112.546484,37.817648;112.546484,37.817648;112.546046,37.817648;112.546046,37.817648;112.545295,37.817648;112.545295,37.817648;112.544501,37.817661;112.544501,37.817661;112.543945,37.817669;112.54326,37.817674;112.54326,37.817674;112.542665,37.817682;112.542665,37.817682;112.541389,37.817695;112.539349,37.817713;112.539349,37.817713;112.539184,37.817717;112.539184,37.817717;112.538728,37.81773;112.538724,37.81773;112.538451,37.817791;112.538398,37.817799;112.537977,37.817808;112.537396,37.817843;112.53737,37.817847;112.537344,37.817873;112.537326,37.817921;112.537326,37.817943;112.537322,37.817943;112.537361,37.818003;112.5374,37.818103;112.5374,37.818103;112.537474,37.818472;112.537517,37.818563;112.537574,37.81865;112.537656,37.81872;112.537747,37.818785;112.537843,37.818832;112.537969,37.81888;112.538203,37.818915;112.538477,37.818915;112.538477,37.818911;112.538707,37.818893;112.538841,37.818841;112.538841,37.818841;112.538984,37.81875;112.538984,37.81875;112.538785,37.81776;112.538702,37.817439;112.53849,37.816771;112.538438,37.81651;112.538438,37.81651;112.53839,37.816233;112.53832,37.81599;112.53832,37.81599;112.538142,37.815234;112.538099,37.814944;112.538064,37.814714;112.53806,37.814709;112.537569,37.814497;112.537569,37.814497;112.537283,37.814379;112.537283,37.814379;112.536875,37.814171;112.536875,37.814171;112.535929,37.813694;112.535929,37.813694;112.535755,37.813602;112.535755,37.813602;112.534453,37.812943;112.534453,37.812943;112.533958,37.812695;112.533958,37.812695;112.53388,37.812652;112.53388,37.812652;112.533676,37.812552;112.533676,37.812552;112.533568,37.812496;112.533568,37.812496;112.533329,37.812378;112.533329,37.812378;112.532552,37.811988;112.532552,37.811988;112.532214,37.811814;112.532214,37.811814;112.531141,37.811259;112.531141,37.811259;112.530642,37.811003;112.530642,37.811003;112.530556,37.810859;112.530556,37.810859;112.530556,37.810321;112.530556,37.810321;112.530556,37.810148;112.530556,37.810148;112.530556,37.809983;112.530556,37.809983;112.530556,37.80967;112.530556,37.80967;112.530556,37.809518;112.530556,37.809518;112.530556,37.808741;112.530556,37.808741;112.530556,37.80865;112.530551,37.808646;112.530326,37.808429;112.530321,37.808424;112.530295,37.808442;112.528164,37.808464;112.52816,37.808464;112.52809,37.808264;112.528064,37.808147;112.528034,37.80809;112.527908,37.807899'
const pathArr = path.split(';').map((i) => {
  const a = i.split(',')
  return { latitude: Number(a[1]), longitude: Number(a[0]) }
})

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

async function ensureLocationPermission() {
  if (Platform.OS !== 'android') return true
  const result = await PermissionsAndroid.requestMultiple([
    PermissionsAndroid.PERMISSIONS.ACCESS_FINE_LOCATION,
    PermissionsAndroid.PERMISSIONS.ACCESS_COARSE_LOCATION
  ])
  const fine =
    result[PermissionsAndroid.PERMISSIONS.ACCESS_FINE_LOCATION] ===
    PermissionsAndroid.RESULTS.GRANTED
  const coarse =
    result[PermissionsAndroid.PERMISSIONS.ACCESS_COARSE_LOCATION] ===
    PermissionsAndroid.RESULTS.GRANTED
  return fine || coarse
}

async function getLocation() {
  const ok = await ensureLocationPermission()
  if (!ok) {
    console.warn('定位权限未授权')
    return
  }
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
      keywords: '重庆',
      city: '023'
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
    console.log(result?.route.paths?.[0].polyline)
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
      origin: { latitude: 37.872547, longitude: 112.519398 },
      destination: { latitude: 37.844896, longitude: 112.596609 },
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
        onTapPolyline={(e) => console.log(e.nativeEvent)}
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
            enabled
            style='teardrop'
            teardropRandomFillColorSeed={point.id}
            teardropInfoText='10:30'
            extra={{
              province: '山西省',
              city: point.city,
              district: point.district
            }}
          />
        ))}
        <Polyline
          id='p1'
          coordinates={pathArr}
          style={{
            fillColor: '#5981D8',
            strokeColor: '#2A56B4',
            lineWidth: 12
          }}
        />
        <Polyline
          id='p2'
          coordinates={pathArr}
          style={{
            lineWidth: 8,
            textureImage:
              'https://qiniu.zdjt.com/shop/2025-08-22/90d820f83205d5fcda3415b13d0d7364.png'
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
