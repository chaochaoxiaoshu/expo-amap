import AMapSearchKit
import ExpoModulesCore
import UIKit

// MARK: - Extensions

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
                    "polyline": path.polyline ?? "",
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
}
