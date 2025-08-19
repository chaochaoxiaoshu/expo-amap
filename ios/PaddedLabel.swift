//
//  PaddedLabel.swift
//  Pods
//
//  Created by 朝小树 on 2025/8/19.
//

import UIKit

class PaddedLabel: UILabel {
    var padding: UIEdgeInsets = UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4)

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + padding.left + padding.right,
            height: size.height + padding.top + padding.bottom
        )
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let originalSize = super.sizeThatFits(CGSize(width: size.width - padding.left - padding.right,
                                                     height: size.height - padding.top - padding.bottom))
        return CGSize(
            width: originalSize.width + padding.left + padding.right,
            height: originalSize.height + padding.top + padding.bottom
        )
    }
}
