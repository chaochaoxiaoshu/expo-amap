import { ExpoConfig, ConfigContext } from 'expo/config'

export default ({ config }: ConfigContext): ExpoConfig => ({
  name: 'expo-amap-example',
  slug: 'expo-amap-example',
  version: '1.0.0',
  orientation: 'portrait',
  icon: './assets/icon.png',
  userInterfaceStyle: 'light',
  newArchEnabled: true,
  splash: {
    image: './assets/splash-icon.png',
    resizeMode: 'contain',
    backgroundColor: '#ffffff'
  },
  ios: {
    supportsTablet: true,
    bundleIdentifier: 'expo.modules.amap.example'
  },
  android: {
    adaptiveIcon: {
      foregroundImage: './assets/adaptive-icon.png',
      backgroundColor: '#ffffff'
    },
    edgeToEdgeEnabled: true,
    package: 'expo.modules.amap.example'
  },
  web: {
    favicon: './assets/favicon.png'
  },
  plugins: [
    [
      '../app.plugin.js',
      {
        apiKey: {
          ios: process.env.EXPO_PUBLIC_AMAP_IOS_API_KEY,
          android: process.env.EXPO_PUBLIC_AMAP_ANDROID_API_KEY
        }
      }
    ]
  ]
})
