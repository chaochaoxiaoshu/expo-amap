import ExpoModulesCore
import React

enum ImageSource {
    case localName(String)
    case remoteURL(URL)
    case base64(String)
}

actor ImageCache {
    static let shared = ImageCache()
    private var cache = NSCache<NSString, UIImage>()

    func image(forKey key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
    }

    func setImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
}

class ImageLoader {
    /// 异步加载单张图片，支持缓存
    static func from(_ value: Any?) async -> UIImage? {
        guard let value = value else { return nil }

        let key: String
        let source: ImageSource

        // 判断来源类型
        if let str = value as? String {
            key = str
            if str.hasPrefix("data:image") {
                source = .base64(str)
            } else if str.hasPrefix("http://") || str.hasPrefix("https://"),
                let url = URL(string: str)
            {
                source = .remoteURL(url)
            } else {
                source = .localName(str)
            }
        } else {
            // 目前只支持 String 类型
            return nil
        }

        // 先从缓存取
        if let cached = await ImageCache.shared.image(forKey: key) {
            return cached
        }

        var image: UIImage? = nil

        switch source {
        case .base64(let str):
            if let data = Data(base64Encoded: str.components(separatedBy: ",").last ?? "") {
                image = UIImage(data: data)
            }
        case .remoteURL(let url):
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                image = UIImage(data: data)
            } catch {
                print("Failed to load image from URL: \(url), error: \(error)")
            }
        case .localName(let name):
            // bundle 或文件路径
            if let img = UIImage(named: name) {
                image = img
            } else if FileManager.default.fileExists(atPath: name) {
                image = UIImage(contentsOfFile: name)
            }
        }

        // 缓存
        if let img = image {
            await ImageCache.shared.setImage(img, forKey: key)
        }

        return image
    }

    /// 同步回调版本（兼容旧接口）
    static func from(_ value: Any?, completion: @escaping (UIImage?) -> Void) {
        Task {
            let img = await from(value)
            DispatchQueue.main.async {
                completion(img)
            }
        }
    }

    /// 异步加载多张图片
    static func loadMultiple(from values: [Any?]) async -> [UIImage?] {
        await withTaskGroup(of: (Int, UIImage?).self) { group in
            for (index, value) in values.enumerated() {
                group.addTask {
                    let img = await from(value)
                    return (index, img)
                }
            }
            var results = [UIImage?](repeating: nil, count: values.count)
            for await (index, img) in group {
                results[index] = img
            }
            return results
        }
    }

    /// 回调版本
    static func loadMultiple(from values: [Any?], completion: @escaping ([UIImage?]) -> Void) {
        Task {
            let results = await loadMultiple(from: values)
            DispatchQueue.main.async {
                completion(results)
            }
        }
    }
}
