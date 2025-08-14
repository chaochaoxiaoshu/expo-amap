import { NativeModule, requireNativeModule } from 'expo'

import { ExpoAmapModuleEvents } from './ExpoAmap.types'

declare class ExpoAmapModule extends NativeModule<ExpoAmapModuleEvents> {
  PI: number
  hello(): string
  setValueAsync(value: string): Promise<void>
}

// This call loads the native module object from the JSI.
export default requireNativeModule<ExpoAmapModule>('ExpoAmap')
