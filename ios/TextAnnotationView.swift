//
//  TextAnnotationView.swift
//  Pods
//
//  Created by 朝小树 on 2025/8/19.
//

import MAMapKit

class TextAnnotationView: MAAnnotationView {

    private let textLabel = PaddedLabel()
    
    var textStyle: TextStyle? {
        didSet {
            updateTextStyle()
        }
    }
    var textOffset: CGPoint? = .zero {
        didSet {
            positionLabel()
        }
    }
    var currentImageURL: String?

    private let minTouchSize: CGSize = CGSize(width: 44, height: 44)

    override init(annotation: MAAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        textLabel.isHidden = true
        addSubview(textLabel)
        bringSubviewToFront(textLabel)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - 设置图片
    func setImage(_ image: UIImage?, url: String?, size: CGSize? = nil) {
        let needsUpdate = currentImageURL != url || image?.size != self.image?.size
        guard needsUpdate else { return }

        self.image = image
        if let size = size {
            self.frame.size = size
        }
        currentImageURL = url
        setNeedsLayout()
        layoutIfNeeded()
    }

    // MARK: - 设置文本
    func setText(_ text: String?) {
        print("TextAnnotationView：设置文本内容：\(text ?? "")")
        if let text = text, !text.isEmpty {
            textLabel.isHidden = false
        }
        
        textLabel.text = text
        textLabel.invalidateIntrinsicContentSize()
        textLabel.sizeToFit()
        updateFrameForLabel()
        positionLabel()
        bringSubviewToFront(textLabel)
        
        updateTextStyle()
    }

    // MARK: - 样式更新
    private func updateTextStyle() {
        print("TextAnnotationView：更新文本样式")
        textLabel.textAlignment = .center

        if let style = textStyle {
            if let hex = style.color { textLabel.textColor = UIColor(hex: hex) }
            textLabel.font = UIFont.systemFont(
                ofSize: style.fontSize ?? 17,
                weight: UIFont.Weight(string: style.fontWeight ?? "") ?? .regular
            )
            textLabel.numberOfLines = style.numberOfLines ?? 1

            if let padding = style.padding {
                textLabel.padding = UIEdgeInsets(top: padding.y, left: padding.x, bottom: padding.y, right: padding.x)
            }
            if let bgHex = style.backgroundColor {
                textLabel.backgroundColor = UIColor(hex: bgHex)
            }
        } else {
            // 默认样式
            textLabel.font = .systemFont(ofSize: 14, weight: .medium)
            textLabel.textColor = .white
            textLabel.padding = UIEdgeInsets(top: 4, left: 6, bottom: 4, right: 6)
            textLabel.backgroundColor = UIColor(hex: "#5981D8")
        }

        textLabel.layer.cornerRadius = 6
        textLabel.layer.cornerCurve = .continuous
        textLabel.layer.masksToBounds = true

        // 更新布局
        textLabel.invalidateIntrinsicContentSize()
        textLabel.sizeToFit()
        updateFrameForLabel()
        positionLabel()
        textLabel.setNeedsLayout()
        textLabel.layoutIfNeeded()
    }

    // MARK: - 更新 annotation view frame 以包含 label
    private func updateFrameForLabel() {
        let labelSize = textLabel.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
        self.frame.size = CGSize(
            width: max(labelSize.width, self.frame.width),
            height: max(labelSize.height, self.frame.height)
        )
    }

    // MARK: - 定位文本
    private func positionLabel() {
        textLabel.center = CGPoint(
            x: bounds.width / 2 + (textOffset?.x ?? 0),
            y: bounds.height / 2 + (textOffset?.y ?? 0)
        )
    }

    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        positionLabel()
        bringSubviewToFront(textLabel)
    }

    override var image: UIImage? {
        didSet { setNeedsLayout() }
    }

    // MARK: - 扩展触摸判定
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let labelFrame = textLabel.frame.insetBy(dx: -textLabel.padding.left, dy: -textLabel.padding.top)
        let imageFrame = self.image != nil ? self.bounds : .zero
        var touchFrame = labelFrame.union(imageFrame)

        if touchFrame.width < minTouchSize.width { touchFrame.size.width = minTouchSize.width }
        if touchFrame.height < minTouchSize.height { touchFrame.size.height = minTouchSize.height }

        return touchFrame.contains(point)
    }
}
