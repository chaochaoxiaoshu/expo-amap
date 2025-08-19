//
//  TeardropView.swift
//  Pods
//
//  Created by 朝小树 on 2025/8/19.
//

class TeardropView: UIView {

    var fillColor: UIColor = UIColor(red: 217/255, green: 217/255, blue: 217/255, alpha: 1) {
        didSet { setNeedsDisplay() }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isOpaque = false
        isUserInteractionEnabled = false
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
        isOpaque = false
        isUserInteractionEnabled = false
    }

    override func draw(_ rect: CGRect) {
        // SVG 原始大小
        let svgWidth: CGFloat = 20
        let svgHeight: CGFloat = 24

        // 适配当前 view 尺寸
        let scaleX = rect.width / svgWidth
        let scaleY = rect.height / svgHeight

        // 创建路径，对应 SVG <path>
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 20, y: 10.0401))
        path.addCurve(to: CGPoint(x: 10, y: 24),
                      controlPoint1: CGPoint(x: 20, y: 17.3295),
                      controlPoint2: CGPoint(x: 10, y: 24))
        path.addCurve(to: CGPoint(x: 0, y: 10.0401),
                      controlPoint1: CGPoint(x: 10, y: 24),
                      controlPoint2: CGPoint(x: 0, y: 17.3295))
        path.addCurve(to: CGPoint(x: 10, y: 0),
                      controlPoint1: CGPoint(x: 0, y: 4.49511),
                      controlPoint2: CGPoint(x: 4.47715, y: 0))
        path.addCurve(to: CGPoint(x: 20, y: 10.0401),
                      controlPoint1: CGPoint(x: 15.5228, y: 0),
                      controlPoint2: CGPoint(x: 20, y: 4.49511))
        path.close()

        // 缩放到 view 尺寸
        let transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
        path.apply(transform)

        // 填充颜色
        fillColor.setFill()
        path.fill()
    }
}
