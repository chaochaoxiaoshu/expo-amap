import { useEffect, useRef } from 'react'
import {
  findNodeHandle,
  InteractionManager,
  View,
  ViewProps
} from 'react-native'
import { MapViewRef } from '../types'

interface CalloutProps extends ViewProps {
  markerId: string
  mapRef: React.RefObject<MapViewRef | null>
}

export function Callout(props: CalloutProps) {
  const ref = useRef<View>(null)

  useEffect(() => {
    const tag = findNodeHandle(ref.current)
    if (tag) {
      InteractionManager.runAfterInteractions(() => {
        props.mapRef.current?._setCustomCalloutViewTag(props.markerId, tag)
      })
    }
  }, [])

  return <View ref={ref}>{props.children}</View>
}
