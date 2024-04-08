//
//  eTagSaverNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 04/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

public

// MARK: - UserDefaults eTag storage

/// Содержит указатель на UserDefaults-хранилище для eTag токенов.
extension UserDefaults {
    /// Хранилище для eTag-токенов
    static var etagStorage = UserDefaults(suiteName: "\(String(describing: self.self))")
}

/// Этот узел сохраняет пришедшие eTag-токены.
/// В качестве ключа используется абсолютный URL до endpoint-a.
open class UrlETagSaverNode: AsyncNode {

    /// Следующий узел для обработки.
    public var next: (any ResponsePostprocessorLayerNode)?

    /// Ключ, по которому необходимо получить eTag-токен из хедеров.
    /// По-молчанию имеет значение `ETagConstants.eTagResponseHeaderKey`
    public var eTagHeaderKey: String

    /// Инициаллизирует узел.
    ///
    /// - Parameters:
    ///   - next: Следующий узел для обработки.
    ///   - eTagHeaderKey: Ключ, по которому необходимо получить eTag-токен из хедеров.
    public init(next: (any ResponsePostprocessorLayerNode)?, eTagHeaderKey: String = ETagConstants.eTagResponseHeaderKey) {
        self.next = next
        self.eTagHeaderKey = eTagHeaderKey
    }

    /// Пытается получить eTag-токен по ключу.
    /// В любом случае передает управление дальше.
    open func process(
        _ data: UrlProcessedResponse,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<Void> {
        guard let tag = data.response.allHeaderFields[self.eTagHeaderKey] as? String,
            let url = data.request.url,
            let urlAsKey = url.withOrderedQuery()
        else {
            return await next?.process(data, logContext: logContext) ?? .success(())
        }

        UserDefaults.etagStorage?.set(tag, forKey: urlAsKey)

        return await next?.process(data, logContext: logContext) ?? .success(())
    }
}

public extension URL {

    /// Берет исходный URL
    /// Получает словарь параметров query
    /// Если параметров нет - возвращает `self.absoluteString`
    /// Если параметры есть - сортирует их соединяет в одну строку
    /// Удаляет query параметры из исходного URL
    /// Склеивает строковое представление URL без парамтеров со сторокой параметров
    ///
    /// **ВАЖНО**
    ///
    /// Полученная строка может быть невалидным URL - т.к. задача этого метода - получить уникальный идентификатор из URL
    /// Причем так, чтобы порядок перечисления query парамтеров был не важен. 
    func withOrderedQuery() -> String? {
        guard var comp = URLComponents(string: self.absoluteString) else {
            return nil
        }

        // ели нет query параметров, то просто возвращаем этот url т.к. ничего сортировать не надо
        if comp.queryItems == nil || comp.queryItems?.isEmpty == true {
            return self.absoluteString
        }

        let ordereedQueryString = comp.queryItems!
            .map { $0.description }
            .sorted()
            .reduce("", { $1 + $0 })

        // если в компонентах сбросить query в nil, то в итоговом URL не будет query
        comp.query = nil

        guard let url = comp.url else {
            return nil
        }

        return url.absoluteString + ordereedQueryString
    }
}
