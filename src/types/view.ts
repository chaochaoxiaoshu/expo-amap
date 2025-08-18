import { ViewProps } from 'react-native'
import { Coordinate, Region } from './base'

/**
 * 地图的缩放级别的范围从 3 到 20 ，共 18 个级别
 */
export type ZoomLevel =
  | 3
  | 4
  | 5
  | 6
  | 7
  | 8
  | 9
  | 10
  | 11
  | 12
  | 13
  | 14
  | 15
  | 16
  | 17
  | 18
  | 19
  | 20

/**
 * 地图类型
 *
 * - 0: 普通地图
 * - 1: 卫星地图
 * - 2: 夜间视图
 * - 3: 导航视图
 * - 4: 公交视图
 * - 5: 导航夜间视图
 */
export type MapType = 0 | 1 | 2 | 3 | 4 | 5

/**
 * - 0: 不追踪用户的location更新
 * - 1: 追踪用户的location更新
 * - 2: 追踪用户的location与heading更新
 */
export type UserTrackingMode = 0 | 1 | 2

/**
 * 折线线段样式
 */
export interface PolylineStyle {
  /**
   * 填充颜色，仅支持 hex 颜色值
   */
  fillColor?: string
  /**
   * 笔触颜色，仅支持 hex 颜色值
   */
  strokeColor?: string
  /**
   * 笔触宽度
   */
  lineWidth?: number
  /**
   * - 0: 斜面连接点
   * - 1: 斜接连接点
   * - 2: 圆角连接点
   */
  lineJoinType?: number
  /**
   * - 0: 普通头
   * - 1: 扩展头
   * - 2: 箭头
   * - 3: 圆形头
   */
  lineCapType?: number
  miterLimit?: number
  /**
   * - 0: 不画虚线
   * - 1: 方块样式
   * - 2: 圆点样式
   */
  lineDashType?: number
  /**
   * 是否抽稀，默认为YES
   */
  reducePoint?: boolean
  /**
   * 是否启用 3d 箭头样式，默认为 false
   */
  is3DArrowLine?: boolean
  /**
   * 设置为立体3d箭头的侧边颜色（当is3DArrowLine为YES时有效)顶部颜色使用strokeColor
   */
  sideColor?: string
  /**
   * 是否开启点击选中功能，默认为 false
   */
  userInteractionEnabled?: boolean
  /**
   * 用于调整点击选中热区大小，默认为0. 负值增大热区，正值减小热区
   */
  hitTestInset?: number
  /**
   * 是否启用显示范围，YES启用，不启用时展示全路径，默认为 false
   */
  showRangeEnabled?: boolean
  /**
   * 显示范围
   */
  pathShowRange?: {
    begin: number
    end: number
  }
  /**
   * 纹理图片，尺寸 64*64
   */
  textureImage?: string
}

/**
 * 折线线段
 */
export interface PolylineData {
  /**
   * 折线坐标点数组
   */
  coordinates: Coordinate[]
  /**
   * 折线样式
   */
  style: PolylineStyle
}

export interface TextStyle {
  color?: string // 文字颜色，默认白色
  fontSize?: number // 字体大小，默认16
  fontWeight?:
    | 'normal'
    | 'bold'
    | '100'
    | '200'
    | '300'
    | '400'
    | '500'
    | '600'
    | '700'
    | '800'
    | '900'
  numberOfLines?: number // 限制行数，超出显示省略号
  offset?: { x: number; y: number } // 文字相对图片中心的偏移
  padding?: { x: number; y: number }
  backgroundColor?: string
}

/**
 * 标记点数据
 */
export interface MarkerData {
  /**
   * 用于引用此 Marker 的唯一标识
   */
  id: string
  /**
   * 标记点坐标
   */
  coordinate: Coordinate
  /**
   * 标记点样式，默认为 pin
   *
   * pin -> 默认的大头针样式
   * custom -> 自定义的 title + 图片 的样式
   */
  style?: 'pin' | 'custom'
  /**
   * 标题
   */
  title?: string
  /**
   * 副标题
   */
  subtitle?: string
  /**
   * 中心偏移量
   */
  centerOffset?: { x: number; y: number }
  /**
   * callout 偏移量
   */
  calloutOffset?: { x: number; y: number }
  /**
   * 文本偏移，style 为 custom 时生效
   */
  textOffset?: { x: number; y: number }
  /**
   * 标记点图像，style 为 custom 时生效
   */
  image?: {
    url: string
    size: { width: number; height: number }
  }
  /**
   * 文本样式，style 为 custom 时生效
   */
  textStyle?: TextStyle
  /**
   * 大头针颜色，style 为 pin 时生效
   */
  pinColor?: 'red' | 'green' | 'purple'
  /**
   * 是否启用触摸事件
   */
  enabled?: boolean
  /**
   * 是否高亮
   */
  highlighted?: boolean
  /**
   * 是否允许弹出callout
   */
  canShowCallout?: boolean
  /**
   * 是否支持拖动
   */
  draggable?: boolean
  /**
   * 弹出默认弹出框时，是否允许地图调整到合适位置来显示弹出框，默认为 true
   */
  canAdjustPosition?: boolean
  /**
   * 额外信息
   */
  extra?: {
    /**
     * 标记点所属的省份
     */
    province?: string
    /**
     * 标记点所属的城市
     */
    city?: string
    /**
     * 标记点所属的区县
     */
    district?: string
  }
}

export interface CustomStyleOptions {
  /**
   * 是否启用自定义样式
   */
  enabled: boolean
  /**
   * 自定义样式的二进制数据，对应下载的自定义地图文件中的style.data中的二进制数据
   */
  styleData?: Uint8Array
  /**
   * 自定义扩展样式的二进制数据,对应下载的自定义地图文件中的style_extra.data中的二进制数据
   */
  styleExtraData?: Uint8Array
}

export interface OnLoadEventPayload {
  message: string
  target: number
  timestamp: number
}

export interface OnZoomEventPayload {
  zoomLevel: number
}

export interface OnRegionChangedEventPayload {
  center: Coordinate
  span: {
    latitudeDelta: number
    longitudeDelta: number
  }
}

export interface OnTapMarkerEventPayload {
  id: string
  point: { x: number; y: number }
}

export interface MapViewRef {
  /**
   * 设置地图中心点
   *
   * @param center - 中心点坐标
   *
   * @example
   * ```tsx
   * const exampleCenter = { latitude: 31.230545, longitude: 121.473724 }
   * mapViewRef.current?.setCenter(exampleCenter)
   * ```
   */
  setCenter: (center: Coordinate) => Promise<void> | undefined
  /**
   * 设置地图缩放级别
   *
   * @param zoomLevel - 缩放级别
   *
   * @example
   * ```tsx
   * mapViewRef.current?.setZoomLevel(15)
   * ```
   */
  setZoomLevel: (zoomLevel: ZoomLevel) => Promise<void> | undefined
}

export interface MapViewProps extends ViewProps {
  ref?: React.Ref<MapViewRef>
  /**
   * 地图显示的初始区域，非受控属性，在组件挂载后更改此属性不会导致区域变化
   */
  initialRegion?: Region
  /**
   * 限制地图显示的区域
   */
  limitedRegion?: Region
  /**
   * 地图类型
   *
   * - 0: 普通地图
   * - 1: 卫星地图
   * - 2: 夜间视图
   * - 3: 导航视图
   * - 4: 公交视图
   * - 5: 导航夜间视图
   */
  mapType?: MapType
  /**
   * 是否显示指南针，默认为 true
   */
  showCompass?: boolean
  /**
   * 是否显示用户位置
   */
  showUserLocation?: boolean
  /**
   * 用户位置更新模式
   *
   * - 0: 不追踪用户的location更新
   * - 1: 追踪用户的location更新
   * - 2: 追踪用户的location与heading更新
   */
  userTrackingMode?: UserTrackingMode
  /**
   * 显示在地图上的标记点
   */
  markers?: MarkerData[]
  /**
   * 显示在地图上的折线
   */
  polylines?: PolylineData[]
  /**
   * 自定义样式
   */
  customStyle?: CustomStyleOptions
  /**
   * 地图语言
   */
  language?: 'chinese' | 'english'
  /**
   * 最小缩放级别
   */
  minZoomLevel?: number
  /**
   * 最大缩放级别
   */
  maxZoomLevel?: number
  /**
   * 行政区划聚合配置，配置行政区划聚合之后，必须在 Marker 中配置 extra 字段
   */
  regionClusteringOptions?: {
    /**
     * 是否启用
     */
    enabled: boolean
    /**
     * 聚合规则
     */
    rules: {
      /**
       * 根据哪个字段聚合
       */
      by: 'district' | 'city' | 'province'
      /**
       * 当 zoomLevel 小于等于该值时，启用行政区划聚合
       */
      thresholdZoomLevel: number
    }[]
  }
  /**
   * 地图加载成功事件
   */
  onLoad?: (event: { nativeEvent: OnLoadEventPayload }) => void
  onZoom?: (event: { nativeEvent: OnZoomEventPayload }) => void
  onRegionChanged?: (event: {
    nativeEvent: OnRegionChangedEventPayload
  }) => void
  onTapMarker?: (event: { nativeEvent: OnTapMarkerEventPayload }) => void
}
