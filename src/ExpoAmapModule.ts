import { NativeModule, requireNativeModule } from 'expo'

import {
  AMapDrivingRouteShowFieldType,
  AMapRidingRouteShowFieldType,
  AMapWalkingRouteShowFieldType,
  OnRouteSearchDoneResult,
  RequestLocationResult,
  SearchDrivingRouteOptions,
  SearchGeocodeOptions,
  SearchGeocodeResult,
  SearchInputTipsOptions,
  SearchInputTipsResult,
  SearchReGeocodeOptions,
  SearchReGeocodeResult,
  SearchRidingRouteOptions,
  SearchTransitRouteOptions,
  SearchWalkingRouteOptions,
  ExpoAmapModuleEvents
} from './types/index'

declare class ExpoAmapModule extends NativeModule<ExpoAmapModuleEvents> {
  /**
   * 单次请求位置
   */
  requestLocation: () => Promise<RequestLocationResult>
  /**
   * 关键字搜索
   *
   * @example
   * ```tsx
   * try {
   *   const result = await ExpoAmapModule.searchInputTips({
   *     keywords: '方圆大厦',
   *     city: '024'
   *   })
   *   console.log('方圆大厦搜索结果:', result)
   * } catch (error) {
   *   console.log((error as Error).message)
   * }
   * ```
   */
  searchInputTips: (
    options: SearchInputTipsOptions
  ) => Promise<SearchInputTipsResult> | undefined
  /**
   * 地理编码请求
   */
  searchGeocode: (
    options: SearchGeocodeOptions
  ) => Promise<SearchGeocodeResult> | undefined
  /**
   * 逆地理编码请求
   */
  searchReGeocode: (
    options: SearchReGeocodeOptions
  ) => Promise<SearchReGeocodeResult> | undefined
  /**
   * 规划驾车路线
   *
   * @param origin - 起点坐标
   * @param destination - 终点坐标
   * @param showFieldType - 显示字段配置，详见 {@link AMapDrivingRouteShowFieldType}
   * @returns 路线信息
   *
   * @example
   * ```tsx
   * try {
   *   const result = await ExpoAmapModule.searchDrivingRoute({
   *     origin: { latitude: 31.230545, longitude: 121.473724 },
   *     destination: { latitude: 39.900896, longitude: 116.401049 },
   *     showFieldType: 'polyline'
   *   })
   *   console.log('🚗 驾车路线规划结果:', result)
   * } catch (error) {
   *   console.log((error as Error).message)
   * }
   * ```
   */
  searchDrivingRoute: (
    options: SearchDrivingRouteOptions
  ) => Promise<OnRouteSearchDoneResult> | undefined
  /**
   * 规划步行路线
   *
   * @param origin - 起点坐标
   * @param destination - 终点坐标
   * @param showFieldType - 显示字段配置，详见 {@link AMapWalkingRouteShowFieldType}
   * @returns 路线信息
   *
   * @example
   * ```tsx
   * try {
   *   const exampleOrigin = { latitude: 31.230545, longitude: 121.473724 }
   *   const exampleDestination = { latitude: 31.228051, longitude: 121.467568 }
   *   const result = await ExpoAmapModule.searchWalkingRoute({
   *     origin: exampleOrigin,
   *     destination: exampleDestination,
   *     showFieldType: 'polyline'
   *   })
   *   console.log('🚶 步行路线规划结果:', result)
   * } catch (error) {
   *   console.log((error as Error).message)
   * }
   * ```
   */
  searchWalkingRoute: (
    options: SearchWalkingRouteOptions
  ) => Promise<OnRouteSearchDoneResult> | undefined
  /**
   * 规划骑行路线
   *
   * @param origin - 起点坐标
   * @param destination - 终点坐标
   * @param showFieldType - 显示字段配置，详见 {@link AMapRidingRouteShowFieldType}
   * @param alternativeRoute - 返回备选方案数目，取值范围为 0-3，0 表示不返回备选方案
   * @returns 路线信息
   *
   * @example
   * ```tsx
   * try {
   *   const exampleOrigin = { latitude: 31.230545, longitude: 121.473724 }
   *   const exampleDestination = { latitude: 31.228051, longitude: 121.467568 }
   *   const result = await ExpoAmapModule.searchRidingRoute({
   *     origin: exampleOrigin,
   *     destination: exampleDestination,
   *     showFieldType: 'polyline'
   *   })
   *   console.log('🚴 骑行路线规划结果:', result)
   * } catch (error) {
   *   console.log((error as Error).message)
   * }
   * ```
   */
  searchRidingRoute: (
    options: SearchRidingRouteOptions
  ) => Promise<OnRouteSearchDoneResult> | undefined
  /**
   * 规划公交路线
   *
   * @param origin - 起点坐标
   * @param destination - 终点坐标
   * @param strategy - 公交换乘策略
   * @param city - 起点城市
   * @param destinationCity - 目的地城市
   * @param nightflag - 是否包含夜班车
   * @param originPOI - 起点 POI
   * @param destinationPOI - 目的地 POI
   * @param adcode - 起点所在行政区域编码
   * @param destinationAdcode - 终点所在行政区域编码
   * @param alternativeRoute - 返回方案条数 可传入1-10的阿拉伯数字，代表返回的不同条数。默认值：5
   * @param multiExport - 是否返回所有地铁出入口
   * @param maxTrans - 最大换乘次数
   * @param date - 请求日期
   * @param time - 请求时间
   * @param showFieldType - 显示字段配置，详见 {@link AMapRidingRouteShowFieldType}
   * @returns 路线信息
   *
   * @example
   * ```tsx
   * try {
   *   const exampleOrigin = { latitude: 31.230545, longitude: 121.473724 }
   *   const exampleDestination = { latitude: 31.228051, longitude: 121.467568 }
   *   const result = await ExpoAmapModule.searchTransitRoute({
   *     origin: exampleOrigin,
   *     destination: exampleDestination,
   *     strategy: 0,
   *     city: '021',
   *     destinationCity: '021',
   *     showFieldType: 'polyline'
   *   })
   *   console.log('🚌 公交路线规划结果:', result)
   * } catch (error) {
   *   console.log((error as Error).message)
   * }
   * ```
   */
  searchTransitRoute: (
    options: SearchTransitRouteOptions
  ) => Promise<OnRouteSearchDoneResult> | undefined
}

export default requireNativeModule<ExpoAmapModule>('ExpoAmap')
