//
//  URLCacheReaderNode.swift
//  CoreNetKitWithExample
//
//  Created by Александр Кравченков on 28/11/2018.
//  Copyright © 2018 Александр Кравченков. All rights reserved.
//

import Foundation

/// Ошибки для узла `URLCacheReaderNode`
///
/// - cantLoadDataFromCache: Случается, если запрос в кэш завершился с ошибкой
/// - cantSerializeJson: Случается, если запрос в кэш завершился успешно, но не удалось сериализовать ответ в JSON
/// - cantCastToJson: Случается, если сериализовать ответ удалось, но каст к `Json` или к `[Json]` завершился с ошибкой
public enum BaseURLCacheReaderError: Error {
    case cantLoadDataFromCache
    case cantSerializeJson
    case cantCastToJson
}

/// Этот узел отвечает за чтение данных из URL кэша.
/// Сам по себе узел является листом и не может быть встроен в сквозную цепочку.
open class URLCacheReaderNode: AsyncNode {

    public var needsToThrowError: Bool

    public init(needsToThrowError: Bool) {
        self.needsToThrowError = needsToThrowError
    }

    /// Посылает запрос в кэш и пытается сериализовать данные в JSON.
    open func process(
        _ data: URLNetworkRequest,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<Json> {
        await .withCheckedCancellation {
            guard let cachedResponse = extractCachedURLResponse(data.urlRequest) else {
                return .failure(BaseURLCacheReaderError.cantLoadDataFromCache)
            }

            guard let jsonObjsect = try? JSONSerialization.jsonObject(
                with: cachedResponse.data,
                options: .allowFragments
            ) else {
                return .failure(BaseURLCacheReaderError.cantSerializeJson)
            }

            guard let json = jsonObjsect as? Json else {
                guard let json = jsonObjsect as? [Json] else {
                    return .failure(BaseURLCacheReaderError.cantCastToJson)
                }
                return .success([MappingUtils.arrayJsonKey: json])
            }

            return .success(json)
        }
    }

    private func extractCachedURLResponse(_ request: URLRequest) -> CachedURLResponse? {
        if let response = URLCache.shared.cachedResponse(for: request) {
            return response
        }
        return nil
    }
}
