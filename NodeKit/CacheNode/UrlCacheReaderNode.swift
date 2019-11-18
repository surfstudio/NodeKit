import Foundation
import Alamofire
import Combine

/// Ошибки для узла `UrlCacheReaderNode`
///
/// - cantLoadDataFromCache: Случается, если запрос в кэш завершился с ошибкой
/// - cantSerializeJson: Случается, если запрос в кэш завершился успешно, но не удалось сериализовать ответ в JSON
/// - cantCastToJson: Случается, если сериализовать ответ удалось, но каст к `Json` или к `[Json]` завершился с ошибкой
public enum BaseUrlCacheReaderError: Error {
    case cantLoadDataFromCache
    case cantSerializeJson
    case cantCastToJson
}

/// Этот узел отвечает за чтение данных из URL кэша.
/// Сам по себе узел является листом и не может быть встроен в сквозную цепочку.
open class UrlCacheReaderNode: Node<UrlNetworkRequest, Json> {

    /// Посылает запрос в кэш и пытается сериализовать данные в JSON.
    open override func process(_ data: UrlNetworkRequest) -> Context<Json> {

        guard let cachedResponse = self.extractCachedUrlResponse(data.urlRequest) else {
            return .emit(error: BaseUrlCacheReaderError.cantLoadDataFromCache)
        }

        guard let jsonObjsect = try? JSONSerialization.jsonObject(with: cachedResponse.data, options: .allowFragments) else {
            return .emit(error: BaseUrlCacheReaderError.cantSerializeJson)
        }

        guard let json = jsonObjsect as? Json else {
            guard let json = jsonObjsect as? [Json] else {
                return .emit(error: BaseUrlCacheReaderError.cantCastToJson)
            }
            return .emit(data: [MappingUtils.arrayJsonKey: json])
        }

        return .emit(data: json)
    }

    @available(iOS 13.0, *)
    open override func make(_ data: UrlNetworkRequest) -> PublisherContext<Json> {
        Just(data)
            .tryMap { model -> CachedURLResponse in
                guard let cachedResponse = self.extractCachedUrlResponse(model.urlRequest) else {
                    throw BaseUrlCacheReaderError.cantLoadDataFromCache
                }
                return cachedResponse
            }.tryMap {
                try JSONSerialization.jsonObject(with: $0.data, options: .allowFragments)
            }.flatMap { jsonObjsect -> PublisherContext<Json>in
                guard let json = jsonObjsect as? Json else {
                    guard let json = jsonObjsect as? [Json] else {
                        return .emit(error: BaseUrlCacheReaderError.cantCastToJson)
                    }
                    return .emit(data: [MappingUtils.arrayJsonKey: json])
                }
                return .emit(data: json)
            }.asContext()
    }

   private func extractCachedUrlResponse(_ request: URLRequest) -> CachedURLResponse? {
        if let response = URLCache.shared.cachedResponse(for: request) {
            return response
        }
        return nil
    }
}
