//
//  Diff.swift
//  Pods
//
//  Created by 朝小树 on 2025/8/18.
//

struct FieldChange {
    let key: String
    let oldValue: Any?
    let newValue: Any?
}

struct DiffResult<U> {
    var toAdd: [U]
    var toUpdate: [(old: U, new: U, changes: [FieldChange])]
    var toRemove: [U]
}

func diffItems<U>(
    oldItems: [U],
    newItems: [U],
    isSame: (U, U) -> Bool,        // 自定义匹配两个对象是否为同一个
    changes: (U, U) -> [FieldChange]  // 返回字段级变化
) -> DiffResult<U> {
    var toAdd: [U] = []
    var toUpdate: [(old: U, new: U, changes: [FieldChange])] = []
    var toRemove: [U] = []

    // 记录旧集合是否已经匹配过
    var matchedOldIndices = Set<Int>()

    for newItem in newItems {
        var foundMatch: Int? = nil
        for (i, oldItem) in oldItems.enumerated() {
            if isSame(oldItem, newItem) {
                foundMatch = i
                break
            }
        }

        if let index = foundMatch {
            matchedOldIndices.insert(index)
            let oldItem = oldItems[index]
            let diff = changes(oldItem, newItem)
            if !diff.isEmpty {
                toUpdate.append((old: oldItem, new: newItem, changes: diff))
            }
        } else {
            toAdd.append(newItem)
        }
    }

    // 删除旧集合中未匹配的元素
    for (i, oldItem) in oldItems.enumerated() {
        if !matchedOldIndices.contains(i) {
            toRemove.append(oldItem)
        }
    }

    return DiffResult(toAdd: toAdd, toUpdate: toUpdate, toRemove: toRemove)
}

func markerChanges(old: Marker, new: Marker) -> [FieldChange] {
    var changes: [FieldChange] = []
    
    if old.coordinate.latitude != new.coordinate.latitude || old.coordinate.longitude != new.coordinate.longitude {
        changes.append(FieldChange(key: "coordinate", oldValue: old.coordinate, newValue: new.coordinate))
    }
    if old.title != new.title {
        changes.append(FieldChange(key: "title", oldValue: old.title, newValue: new.title))
    }
    if old.subtitle != new.subtitle {
        changes.append(FieldChange(key: "subtitle", oldValue: old.subtitle, newValue: new.subtitle))
    }
    if old.centerOffset?.x != new.centerOffset?.x || old.centerOffset?.y != new.centerOffset?.y {
        changes.append(FieldChange(key: "centerOffset", oldValue: old.centerOffset, newValue: new.centerOffset))
    }
    if old.calloutOffset?.x != new.calloutOffset?.x || old.calloutOffset?.y != new.calloutOffset?.y {
        changes.append(FieldChange(key: "calloutOffset", oldValue: old.calloutOffset, newValue: new.calloutOffset))
    }
    if old.textOffset?.x != new.textOffset?.x || old.textOffset?.y != new.textOffset?.y {
        changes.append(FieldChange(key: "textOffset", oldValue: old.textOffset, newValue: new.textOffset))
    }
    if old.image?.url != new.image?.url || old.image?.size.width != new.image?.size.width || old.image?.size.height != new.image?.size.height {
        changes.append(FieldChange(key: "image", oldValue: old.image, newValue: new.image))
    }
    if old.textStyle?.color != new.textStyle?.color || old.textStyle?.fontSize != new.textStyle?.fontSize || old.textStyle?.fontWeight != new.textStyle?.fontWeight || old.textStyle?.numberOfLines != new.textStyle?.numberOfLines || old.textStyle?.backgroundColor != new.textStyle?.backgroundColor || old.textStyle?.padding?.x != new.textStyle?.padding?.x || old.textStyle?.padding?.y != new.textStyle?.padding?.y {
        changes.append(FieldChange(key: "textStyle", oldValue: old.textStyle, newValue: new.textStyle))
    }
    if old.pinColor != new.pinColor {
        changes.append(FieldChange(key: "pinColor", oldValue: old.pinColor, newValue: new.pinColor))
    }
    if old.teardropLabel != new.teardropLabel {
        changes.append(FieldChange(key: "teardropLabel", oldValue: old.teardropLabel, newValue: new.teardropLabel))
    }
    if old.teardropRandomFillColorSeed != new.teardropRandomFillColorSeed {
        changes.append(FieldChange(key: "teardropRandomFillColorSeed", oldValue: old.teardropRandomFillColorSeed, newValue: new.teardropRandomFillColorSeed))
    }
    if old.teardropFillColor != new.teardropFillColor {
        changes.append(FieldChange(key: "teardropFillColor", oldValue: old.teardropFillColor, newValue: new.teardropFillColor))
    }
    if old.teardropInfoText != new.teardropInfoText {
        changes.append(FieldChange(key: "teardropInfoText", oldValue: old.teardropInfoText, newValue: new.teardropInfoText))
    }
    if old.enabled != new.enabled {
        changes.append(FieldChange(key: "enabled", oldValue: old.enabled, newValue: new.enabled))
    }
    if old.highlighted != new.highlighted {
        changes.append(FieldChange(key: "highlighted", oldValue: old.highlighted, newValue: new.highlighted))
    }
    if old.canShowCallout != new.canShowCallout {
        changes.append(FieldChange(key: "canShowCallout", oldValue: old.canShowCallout, newValue: new.canShowCallout))
    }
    if old.draggable != new.draggable {
        changes.append(FieldChange(key: "draggable", oldValue: old.draggable, newValue: new.draggable))
    }
    if old.canAdjustPosition != new.canAdjustPosition {
        changes.append(FieldChange(key: "canAdjustPosition", oldValue: old.canAdjustPosition, newValue: new.canAdjustPosition))
    }
    if old.extra?.province != new.extra?.province || old.extra?.district != new.extra?.district || old.extra?.city != new.extra?.city {
        changes.append(FieldChange(key: "extra", oldValue: old.extra, newValue: new.extra))
    }
    
    return changes
}
