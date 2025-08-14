/**
 * 经纬度坐标
 */
export interface Coordinate {
  /**
   * 纬度
   */
  latitude: number
  /**
   * 经度
   */
  longitude: number
}

/**
 * 以特定经纬度为中心的矩形地理区域
 */
export interface Region {
  center: Coordinate
  span: {
    latitudeDelta: number
    longitudeDelta: number
  }
}
