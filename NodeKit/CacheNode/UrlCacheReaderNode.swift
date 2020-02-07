//
//  UrlCacheReaderNode.swift
//  CoreNetKitWithExample
//
//  Created by Александр Кравченков on 28/11/2018.
//  Copyright © 2018 Александр Кравченков. All rights reserved.
//

import Foundation
import Alamofire

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


    public var needsToThrowError: Bool

    public init(needsToThrowError: Bool) {
        self.needsToThrowError = needsToThrowError
    }

    /// Посылает запрос в кэш и пытается сериализовать данные в JSON.
    open override func process(_ data: UrlNetworkRequest) -> Context<Json> {

        guard let cachedResponse = self.extractCachedUrlResponse(data.urlRequest) else {
            return self.needsToThrowError ? .emit(error: BaseUrlCacheReaderError.cantLoadDataFromCache) : Context<Json>()
        }

        guard let jsonObjsect = try? JSONSerialization.jsonObject(with: cachedResponse.data, options: .allowFragments) else {
            return self.needsToThrowError ? .emit(error: BaseUrlCacheReaderError.cantSerializeJson) : Context<Json>()
        }

        guard let json = jsonObjsect as? Json else {
            guard let json = jsonObjsect as? [Json] else {
                return self.needsToThrowError ? .emit(error: BaseUrlCacheReaderError.cantCastToJson) : Context<Json>()
            }
            return .emit(data: [MappingUtils.arrayJsonKey: json])
        }

        return .emit(data: json)
    }

   private func extractCachedUrlResponse(_ request: URLRequest) -> CachedURLResponse? {
        if let response = URLCache.shared.cachedResponse(for: request) {
            return response
        }
        return nil
    }
}
