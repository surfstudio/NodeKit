//
//  eTagSaverNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 04/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

// MARK: - UserDefaults eTag storage

/// Содержит указатель на UserDefaults-хранилище для eTag токенов.
extension UserDefaults {
    /// Хранилище для eTag-токенов
    static var etagStorage = UserDefaults(suiteName: "\(String(describing: self.self))")
}

/// Этот узел сохраняет пришедшие eTag-токены.
/// В качестве ключа используется абсолютный URL до endpoint-a.
open class UrlETagSaverNode: ResponsePostprocessorLayerNode {

    /// Следующий узел для обработки.
    public var next: ResponsePostprocessorLayerNode?

    /// Ключ, по которому необходимо получить eTag-токен из хедеров.
    /// По-молчанию имеет значение `ETagConstants.eTagResponseHeaderKey`
    public var eTagHeaderKey: String

    /// Инициаллизирует узел.
    ///
    /// - Parameters:
    ///   - next: Следующий узел для обработки.
    ///   - eTagHeaderKey: Ключ, по которому необходимо получить eTag-токен из хедеров.
    public init(next: ResponsePostprocessorLayerNode?, eTagHeaderKey: String = ETagConstants.eTagResponseHeaderKey) {
        self.next = next
        self.eTagHeaderKey = eTagHeaderKey
    }

    /// Пытается получить eTag-токен по ключу `UrlETagSaverNode.eTagHeaderKey`.
    /// В любом случае передает управление дальше.
    open override func process(_ data: UrlProcessedResponse<Json>) -> Observer<Void> {
        guard let tag = data.response.allHeaderFields[self.eTagHeaderKey] as? String,
            let url = data.request.url else {
            return .emit(data: ())
        }

        UserDefaults.etagStorage?.set(tag, forKey: url.absoluteString)

        return next?.process(data) ?? .emit(data: ())
    }
}
