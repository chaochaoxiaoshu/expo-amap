import { Coordinate } from './base'

/**
 * 显示字段配置，默认为 none
 *
 * - none: 不返回扩展信息
 * - cost: 返回方案所需时间及费用成本
 * - tmcs: 返回分段路况详情
 * - navi: 返回详细导航动作指令
 * - cities: 返回分段途径城市信息
 * - polyline: 返回分段路坐标点串，两点间用“,”分隔
 * - newEnergy: 返回分段路坐标点串，两点间用“,”分隔
 * - all: 返回所有扩展信息
 */
export type AMapDrivingRouteShowFieldType =
  | 'none'
  | 'cost'
  | 'tmcs'
  | 'navi'
  | 'cities'
  | 'polyline'
  | 'newEnergy'
  | 'all'

export type AMapWalkingRouteShowFieldType =
  | 'none'
  | 'cost'
  | 'navi'
  | 'polyline'
  | 'all'

export type AMapRidingRouteShowFieldType =
  | 'none'
  | 'cost'
  | 'navi'
  | 'polyline'
  | 'all'

export type AMapTransitRouteShowFieldType =
  | 'none'
  | 'cost'
  | 'navi'
  | 'polyline'
  | 'all'

export interface AMapPath {
  distance: number
  duration: number
  stepCount: number
  polyline?: Coordinate[]
  [key: string]: any
}

/**
 * 公交换乘信息
 */
export interface AMapTransit {
  /**
   * 此公交方案价格（单位：元）
   */
  cost: number
  /**
   * 此换乘方案预期时间（单位：秒）
   */
  duration: number
  /**
   * 是否是夜班车
   */
  nightflag: boolean
  /**
   * 此方案总步行距离（单位：米）
   */
  walkingDistance: number
  // /**
  //  * 换乘路段 AMapSegment 数组
  //  */
  // segments: any[]
  /**
   * 当前方案的总距离
   */
  distance: number
}

/**
 * 导航动作
 */
export interface AMapTransitNavi {
  action: string
  assistantAction: string
}

/**
 * 路径规划信息
 */
export interface AMapSearchObject {
  /**
   * 起点坐标
   */
  origin?: Coordinate
  /**
   * 终点坐标
   */
  destination?: Coordinate
  /**
   * 出租车费用（单位：元）
   */
  taxiCost: number
  /**
   * 步行、骑行、驾车方案列表 AMapPath 数组
   */
  paths?: AMapPath[]
  /**
   * 公交换乘方案列表 AMapTransit 数组
   */
  transits?: AMapTransit[]
  /**
   * 详细导航动作指令
   */
  transitNavi?: AMapTransitNavi
  /**
   * 分路段坐标点串，两点间用“,”分隔
   */
  polyline?: string
}

export interface SearchInputTipsOptions {
  /**
   * 搜索关键字
   */
  keywords: string
  /**
   * 指定查询城市
   */
  city?: string
  /**
   * 指定查询类型，多个类型用 | 分隔
   */
  types?: string
  /**
   * 是否限制在 city 内搜索
   */
  cityLimit?: boolean
  /**
   * 位置坐标，经纬度坐标，经度在前，纬度在后，用逗号分隔
   */
  location?: string
}

export interface SearchInputTip {
  uid: string
  name: string
  address: string
  adcode: string
  district: string
  typecode: string
}

export interface SearchInputTipsResult {
  /**
   * 搜索结果数目
   */
  count: number
  /**
   * 搜索结果
   */
  tips: SearchInputTip[]
}

export interface SearchGeocodeOptions {
  address?: string
  city?: string
  country?: string
}

export interface SearchGeocodeResult {
  count: number
  geocodes: {
    adcode: string
    building: string
    city: string
    citycode: string
    country: string
    district: string
    formattedAddress: string
    level: string
    neighborhood: string
    postcode: string
    province: string
    township: string
  }[]
}

export interface SearchReGeocodeOptions {
  requireExtension?: boolean
  location?: Coordinate
  radius?: number
  poitype?: string
  mode?: string
}

export interface SearchReGeocodeResult {
  formattedAddress: string
  addressComponent: {
    adcode: string
    building: string
    city: string
    citycode: string
    country: string
    countryCode: string
    district: string
    neighborhood: string
    province: string
    towncode: string
    township: string
  }
  aois: {
    adcode: string
    name: string
    type: string
    uid: string
  }[]
  pois: {
    adcode: string
    address: string
    businessArea: string
    city: string
    citycode: string
    direction: string
    district: string
    email: string
    gridcode: string
    name: string
    naviPOIId: string
    parkingType: string
    pcode: string
    postcode: string
    province: string
    shopID: string
    tel: string
    type: string
    typecode: string
    uid: string
    website: string
  }[]
  roadinters: {
    direction: string
    firstId: string
    firstName: string
    secondId: string
    secondName: string
  }[]
  roads: {
    direction: string
    name: string
    uid: string
  }[]
}

export interface SearchDrivingRouteOptions {
  /**
   * 起点坐标
   */
  origin: Coordinate
  /**
   * 终点坐标
   */
  destination: Coordinate
  /**
   * 显示字段配置，详见 {@link AMapDrivingRouteShowFieldType}
   */
  showFieldType?: AMapDrivingRouteShowFieldType
}

export interface SearchWalkingRouteOptions {
  /**
   * 起点坐标
   */
  origin: Coordinate
  /**
   * 终点坐标
   */
  destination: Coordinate
  /**
   * 显示字段配置，详见 {@link AMapWalkingRouteShowFieldType}
   */
  showFieldType?: AMapWalkingRouteShowFieldType
}

export type SearchRidingRouteOptions = {
  /**
   * 起点坐标
   */
  origin: Coordinate
  /**
   * 终点坐标
   */
  destination: Coordinate
  /**
   * 显示字段配置，详见 {@link AMapRidingRouteShowFieldType}
   */
  showFieldType?: AMapRidingRouteShowFieldType
  /**
   * 返回备选方案数目，取值范围为 0-3，0 表示不返回备选方案
   */
  alternativeRoute?: number
}

export interface SearchTransitRouteOptions {
  /**
   * 起点坐标
   */
  origin: Coordinate
  /**
   * 终点坐标
   */
  destination: Coordinate
  /**
   * 公交换乘策略，默认为 0
   *
   * - 0：推荐模式，综合权重，同高德APP默认
   * - 1：最经济模式，票价最低
   * - 2：最少换乘模式，换乘次数少
   * - 3：最少步行模式，尽可能减少步行距离
   * - 4：最舒适模式，尽可能乘坐空调车
   * - 5：不乘地铁模式，不乘坐地铁路线
   * - 6：地铁图模式，起终点都是地铁站（地铁图模式下originpoi及destinationpoi为必填项）
   * - 7：地铁优先模式，步行距离不超过4KM
   * - 8：时间短模式，方案花费总时间最少
   */
  strategy: number
  /**
   * 起点城市，必填，仅支持citycode
   */
  city: string
  /**
   * 目的地城市，必填，仅支持citycode，与city相同时代表同城，不同时代表跨城
   */
  destinationCity: string
  /**
   * 是否包含夜班车，默认为 false
   */
  nightflag?: boolean
  /**
   * 起点 POI
   */
  originPOI?: string
  /**
   * 目的地 POI
   */
  destinationPOI?: string
  /**
   * 起点所在行政区域编码
   */
  adcode?: string
  /**
   * 终点所在行政区域编码
   */
  destinationAdcode?: string
  /**
   * 返回方案条数 可传入1-10的阿拉伯数字，代表返回的不同条数。默认值：5
   */
  alternativeRoute?: number
  /**
   * 是否返回所有地铁出入口，默认为 false
   */
  multiExport?: boolean
  /**
   * 最大换乘次数: 0：直达 1：最多换乘1次 2：最多换乘2次 3：最多换乘3次 4：最多换乘4次。默认值：4
   */
  maxTrans?: number
  /**
   * 请求日期，格式为 "YYYY-MM-DD"
   */
  date?: string
  /**
   * 请求时间，格式为 "HH:mm"
   */
  time?: string
  /**
   * 显示字段配置，详见 {@link AMapTransitRouteShowFieldType}
   */
  showFieldType?: AMapTransitRouteShowFieldType
}

export interface OnRouteSearchDoneResult {
  success: boolean
  /**
   * 路径规划信息数目
   */
  count: number
  /**
   * 路径规划信息
   */
  route: AMapSearchObject
}
