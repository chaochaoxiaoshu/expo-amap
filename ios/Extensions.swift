import AMapSearchKit
import CryptoKit
import ExpoModulesCore
import UIKit

struct OKLCH {
    var l: Double
    var c: Double
    var h: Double
}

extension UIColor {
    convenience init(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hexString.hasPrefix("#") { hexString.removeFirst() }

        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)

        if hexString.count == 6 {
            self.init(
                red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                alpha: 1.0
            )
        } else if hexString.count == 8 {
            self.init(
                red: CGFloat((rgbValue & 0xFF00_0000) >> 24) / 255.0,
                green: CGFloat((rgbValue & 0x00FF_0000) >> 16) / 255.0,
                blue: CGFloat((rgbValue & 0x0000_FF00) >> 8) / 255.0,
                alpha: CGFloat(rgbValue & 0x0000_00FF) / 255.0
            )
        } else {
            self.init(white: 0, alpha: 1)
        }
    }
    
    /// 根据 OKLCH 创建 UIColor（兼容 iOS 15）
    static func fromOKLCH(_ oklch: OKLCH, alpha: CGFloat = 1.0) -> UIColor {
        // 1. OKLCH -> OKLab
        let hRad = oklch.h * Double.pi / 180
        let a = oklch.c * cos(hRad)
        let b = oklch.c * sin(hRad)
        let l = oklch.l
        
        // 2. OKLab -> Linear sRGB
        let l_ = l + 0.3963377774 * a + 0.2158037573 * b
        let m_ = l - 0.1055613458 * a - 0.0638541728 * b
        let s_ = l - 0.0894841775 * a - 1.2914855480 * b
        
        func cube(_ x: Double) -> Double { x * x * x }
        func f(_ x: Double) -> Double { cube(x) }
        
        var r1 =  4.0767416621 * f(l_) - 3.3077115913 * f(m_) + 0.2309699292 * f(s_)
        var g1 = -1.2684380046 * f(l_) + 2.6097574011 * f(m_) - 0.3413193965 * f(s_)
        var b1 = -0.0041960863 * f(l_) - 0.7034186147 * f(m_) + 1.7076147010 * f(s_)
        
        // 3. Linear sRGB -> sRGB
        func linearToSRGB(_ x: Double) -> CGFloat {
            if x <= 0.0031308 { return CGFloat(max(0, x * 12.92)) }
            return CGFloat(min(1, 1.055 * pow(x, 1/2.4) - 0.055))
        }
        
        return UIColor(
            red: linearToSRGB(r1),
            green: linearToSRGB(g1),
            blue: linearToSRGB(b1),
            alpha: alpha
        )
    }
    
    /// 根据字符串生成固定亮度/饱和度的 OKLCH 颜色
    static func random(seed: String, lightness: Double = 0.7, chroma: Double = 0.2, alpha: CGFloat = 1.0) -> UIColor {
        let hash = SHA256.hash(data: Data(seed.utf8))
        let value = hash.withUnsafeBytes { ptr -> UInt64 in
            return ptr.load(as: UInt64.self)
        }
        let hue = Double(value % 360)
        let oklch = OKLCH(l: lightness, c: chroma, h: hue)
        return UIColor.fromOKLCH(oklch, alpha: alpha)
    }
}

extension UIFont.Weight {
    init?(string: String) {
        switch string.lowercased() {
        case "normal", "400":
            self = .regular
        case "bold", "700":
            self = .bold
        case "100":
            self = .ultraLight
        case "200":
            self = .thin
        case "300":
            self = .light
        case "500":
            self = .medium
        case "600":
            self = .semibold
        case "800":
            self = .heavy
        case "900":
            self = .black
        default:
            return nil
        }
    }
}

extension NSTextAlignment {
    init?(string: String) {
        switch string.lowercased() {
        case "left":
            self = .left
        case "center":
            self = .center
        case "right":
            self = .right
        default:
            return nil
        }
    }
}

extension UIImage {
    func resized(to targetSize: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}

class Utils {
    static func serializeRouteResponse(_ route: AMapRoute) -> [String: Any] {
        var routeData: [String: Any] = [:]

        // 序列化起点
        if let origin = route.origin {
            routeData["origin"] = [
                "latitude": Double(origin.latitude),
                "longitude": Double(origin.longitude),
            ]
        }

        // 序列化终点
        if let destination = route.destination {
            routeData["destination"] = [
                "latitude": Double(destination.latitude),
                "longitude": Double(destination.longitude),
            ]
        }

        // 出租车费用
        routeData["taxiCost"] = Double(route.taxiCost)

        // 分路段坐标点串
        routeData["polyline"] = route.polyline ?? ""

        // 序列化路径列表 (AMapPath 数组)
        if let paths = route.paths {
            var pathsArray: [[String: Any]] = []
            for path in paths {
                let pathData: [String: Any] = [
                    "distance": Double(path.distance),
                    "duration": Double(path.duration),
                    "stepCount": path.steps.count,
                    // 将形如 "lon,lat;lon,lat;..." 的字符串格式化为坐标数组
                    "polyline": Utils.parsePolyline(path.polyline),
                ]
                pathsArray.append(pathData)
            }
            routeData["paths"] = pathsArray
        }

        // 序列化公交换乘方案列表 (AMapTransit 数组)
        if let transits = route.transits {
            var transitsArray: [[String: Any]] = []
            for transit in transits {
                let transitData: [String: Any] = [
                    "cost": Double(transit.cost),
                    "duration": Double(transit.duration),
                    "nightflag": transit.nightflag,
                    "walkingDistance": Double(transit.walkingDistance),
                    "distance": Double(transit.distance),
                ]
                transitsArray.append(transitData)
            }
            routeData["transits"] = transitsArray
        }

        // 序列化详细导航动作指令
        if let transitNavi = route.transitNavi {
            routeData["transitNavi"] = [
                "action": transitNavi.action ?? "",
                "assistantAction": transitNavi.assistantAction ?? "",
            ]
        }

        return routeData
    }

    /// 将 "lon,lat;lon,lat;..." 解析为 [{ latitude, longitude }]
    static func parsePolyline(_ polyline: String?) -> [[String: Double]] {
        guard let s = polyline, !s.isEmpty else { return [] }
        return s
            .split(separator: ";")
            .compactMap { pair -> [String: Double]? in
                let parts = pair.split(separator: ",")
                guard parts.count >= 2,
                      let lon = Double(parts[0]),
                      let lat = Double(parts[1]) else { return nil }
                return [
                    "latitude": lat,
                    "longitude": lon,
                ]
            }
    }
}
