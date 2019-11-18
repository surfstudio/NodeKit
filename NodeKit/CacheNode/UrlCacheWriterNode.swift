import Foundation
import Combine
/// Этот узел занимается записью данных в URL кэш.
/// - Important: это "глупая" реализация,
/// в которой не учитываются server-side политики и прочее.
/// Подразумечается, что этот узел не входит в цепочку, а является листом одного из узлов.
open class UrlCacheWriterNode: Node<UrlProcessedResponse, Void> {

    /// Формирует `CachedURLResponse` с политикой `.allowed`, сохраняет его в кэш,
    /// а затем возвращает сообщение об успешной операции.
    open override func process(_ data: UrlProcessedResponse) -> Context<Void> {
        let cahced = CachedURLResponse(response: data.response, data: data.data, storagePolicy: .allowed)
        URLCache.shared.storeCachedResponse(cahced, for: data.request)
        return Context<Void>().emit(data: ())
    }

    @available(iOS 13.0, *)
    open override func make(_ data: UrlProcessedResponse) -> PublisherContext<Void> {
        Just(data)
            .map { CachedURLResponse(response: $0.response, data: $0.data, storagePolicy: .allowed) }
            .map { URLCache.shared.storeCachedResponse($0, for: data.request) }
            .setFailureType(to: Error.self)
            .asContext()
    }
}
