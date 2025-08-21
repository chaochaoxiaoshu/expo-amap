//
//  TeardropAnnotationView.swift
//  Pods
//
//  Created by 朝小树 on 2025/8/19.
//

import MAMapKit

class TeardropAnnotationView: MAAnnotationView {
    
    let teardrop = TeardropView()
    private let textLabel = UILabel()
    private let circleView = OutlinedCircleView()
    
    private let infoView = UIView()
    private let infoIcon = UIImageView()
    private let infoLabel = UILabel()
    
    var label: String? {
        didSet { updateContent() }
    }
    
    var infoText: String? {
        didSet { updateInfoView() }
    }
    
    private let minTouchSize: CGSize = CGSize(width: 44, height: 44)
    
    override init(annotation: MAAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.frame = CGRect(x: 0, y: 0, width: 20, height: 24)
        self.centerOffset = CGPoint(x: 0, y: -12)
        setupTeardropView()
        setupContentViews()
        setupInfoView()
        updateContent()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupTeardropView() {
        teardrop.frame = bounds
        teardrop.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(teardrop)
    }

    private func setupContentViews() {
        // Label
        textLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        textLabel.textColor = .white
        textLabel.textAlignment = .center
        textLabel.adjustsFontSizeToFitWidth = true
        textLabel.isHidden = true
        addSubview(textLabel)
        
        // Circle
        circleView.isHidden = true
        addSubview(circleView)
    }
    
    private func setupInfoView() {
        infoView.isHidden = true
        infoView.backgroundColor = .white
        infoView.layer.cornerRadius = 12
        infoView.layer.borderWidth = 0.5
        infoView.layer.borderColor = UIColor.lightGray.cgColor
        infoView.layer.shadowColor = UIColor.black.cgColor
        infoView.layer.shadowOpacity = 0.15
        infoView.layer.shadowOffset = CGSize(width: 0, height: 2)
        infoView.layer.shadowRadius = 3
        
        // Icon
        let clockImage = UIImage(systemName: "clock")?.withRenderingMode(.alwaysTemplate)
        infoIcon.image = clockImage
        infoIcon.tintColor = .darkGray
        infoIcon.contentMode = .scaleAspectFit
        
        // Label
        infoLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        infoLabel.textColor = .black
        
        infoView.addSubview(infoIcon)
        infoView.addSubview(infoLabel)
        addSubview(infoView)
    }
    
    private func updateContent() {
        if let text = label, !text.isEmpty {
            textLabel.text = text
            textLabel.isHidden = false
            circleView.isHidden = true
            
            textLabel.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        } else {
            textLabel.isHidden = true
            circleView.isHidden = false
            
            let size: CGFloat = 10
            circleView.frame = CGRect(x: (bounds.width - size) / 2, y: (bounds.width - size) / 2, width: size, height: size)
        }
    }
    
    private func updateInfoView() {
        guard let text = infoText, !text.isEmpty else {
            infoView.isHidden = true
            return
        }
        
        infoLabel.text = text
        infoView.isHidden = false
        
        // 布局
        let padding: CGFloat = 8
        let iconSize: CGFloat = 14
        let labelSize = (text as NSString).size(withAttributes: [.font: infoLabel.font!])
        let totalWidth = padding + iconSize + 4 + labelSize.width + padding
        let height: CGFloat = 24
        
        infoView.frame = CGRect(
            x: -(totalWidth - bounds.width) / 2,
            y: -height - 6,  // 在水滴上方
            width: totalWidth,
            height: height
        )
        
        infoIcon.frame = CGRect(x: padding, y: (height - iconSize) / 2, width: iconSize, height: iconSize)
        infoLabel.frame = CGRect(x: padding + iconSize + 4, y: 0, width: labelSize.width, height: height)
    }
}

class OutlinedCircleView: UIView {

    var strokeColor: UIColor = .white {
        didSet { layer.borderColor = strokeColor.cgColor }
    }

    var lineWidth: CGFloat = 2 {
        didSet { layer.borderWidth = lineWidth }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        backgroundColor = .clear
        isOpaque = false
        isUserInteractionEnabled = false
        layer.cornerRadius = min(bounds.width, bounds.height) / 2
        layer.borderWidth = lineWidth
        layer.borderColor = strokeColor.cgColor
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = min(bounds.width, bounds.height) / 2
    }
}
