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
    
    var label: String? {
        didSet { updateContent() }
    }
    
    private let minTouchSize: CGSize = CGSize(width: 44, height: 44)
    
    override init(annotation: MAAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.frame = CGRect(x: 0, y: 0, width: 20, height: 24)
        self.centerOffset = CGPoint(x: 0, y: -12)
        setupTeardropView()
        setupContentViews()
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
