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
