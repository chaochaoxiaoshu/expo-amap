import Foundation

class PromiseDelegateHandler<ResultType> {
    private var resolve: ((ResultType) -> Void)?
    private var reject: ((String, String, Error?) -> Void)?

    /// 开始一次 Promise 绑定
    func begin(
        resolve: @escaping (ResultType) -> Void,
        reject: @escaping (String, String, Error?) -> Void
    ) {
        self.resolve = resolve
        self.reject = reject
    }

    /// 成功时调用
    func finishSuccess(_ result: ResultType) {
        resolve?(result)
        clear()
    }

    /// 失败时调用
    func finishFailure(code: String, message: String, error: Error? = nil) {
        reject?(code, message, error)
        clear()
    }

    /// 清理回调
    private func clear() {
        resolve = nil
        reject = nil
    }

    /// 是否正在等待回调（可选）
    var isPending: Bool {
        return resolve != nil || reject != nil
    }
}
