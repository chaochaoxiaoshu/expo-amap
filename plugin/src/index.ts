import {
  AndroidConfig,
  ConfigPlugin,
  withAndroidManifest,
  withInfoPlist
} from 'expo/config-plugins'

const withAMapConfig: ConfigPlugin<{
  apiKey?: { ios?: string; android?: string }
}> = (config, { apiKey }) => {
  config = withInfoPlist(config, (config) => {
    const plist = config.modResults

    // 写入 apiKey
    const iosApiKey = apiKey?.ios
    if (iosApiKey) {
      plist['AMAP_API_KEY'] = iosApiKey
    }

    // 添加 NSAppTransportSecurity 节点
    if (!plist.NSAppTransportSecurity) {
      plist.NSAppTransportSecurity = {
        NSAllowsArbitraryLoads: false,
        NSAllowsLocalNetworking: true
      }
    }

    // 添加定位权限描述
    if (!plist.NSLocationAlwaysAndWhenInUseUsageDescription) {
      plist.NSLocationAlwaysAndWhenInUseUsageDescription =
        '应用需要访问您的位置，以提供地图相关功能。'
    }
    if (!plist.NSLocationWhenInUseUsageDescription) {
      plist.NSLocationWhenInUseUsageDescription =
        '应用需要访问您的位置，以提供地图相关功能。'
    }

    return config
  })

  config = withAndroidManifest(config, (config) => {
    const mainApplication = AndroidConfig.Manifest.getMainApplicationOrThrow(
      config.modResults
    )

    const androidApiKey = apiKey?.android
    if (androidApiKey) {
      AndroidConfig.Manifest.addMetaDataItemToMainApplication(
        mainApplication,
        'com.amap.api.v2.apikey',
        androidApiKey
      )
    }
    return config
  })

  return config
}

export default withAMapConfig
