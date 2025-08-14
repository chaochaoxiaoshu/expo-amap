import { requireNativeView } from 'expo'
import * as React from 'react'

import { ExpoAmapViewProps } from './ExpoAmap.types'

const NativeView: React.ComponentType<ExpoAmapViewProps> =
  requireNativeView('ExpoAmap')

export default function ExpoAmapView(props: ExpoAmapViewProps) {
  return <NativeView {...props} />
}
