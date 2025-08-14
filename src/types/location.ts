export interface RequestLocationResult {
  /**
   * 纬度
   */
  latitude: number
  /**
   * 经度
   */
  longitude: number
  /**
   * 逆地理编码信息
   */
  regeocode: {
    /**
     * 逆地理编码地址
     */
    formattedAddress?: string
    /**
     * 国家
     */
    country?: string
    /**
     * 省份
     */
    province?: string
    /**
     * 城市
     */
    city?: string
    /**
     * 区县
     */
    district?: string
    /**
     * 城市编码
     */
    citycode?: string
    /**
     * 区县编码
     */
    adcode?: string
    /**
     * 街道
     */
    street?: string
    /**
     * 门牌号
     */
    number?: string
    /**
     * 兴趣点名称
     */
    poiName?: string
    /**
     * 兴趣点名称
     */
    aoiName?: string
  }
}
