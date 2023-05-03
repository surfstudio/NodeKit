//
//  EtagReaderNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 05/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// Этот узел читает eTag-токен из хранилища и добавляет его к запросу.
open class UrlETagReaderNode<Type>: Node<TransportUrlRequest, Type> {

    // Следующий узел для обработки.
    public var next: Node<TransportUrlRequest, Type>

    /// Ключ, по которому необходимо получить eTag-токен из хедеров.
    /// По-молчанию имеет значение `eTagRequestHeaderKey`
    public var etagHeaderKey: String

    /// Инициаллизирует узел.
    ///
    /// - Parameters:
    ///   - next: Следующий узел для обработки.
    ///   - eTagHeaderKey: Ключ, по которому необходимо добавить eTag-токен к запросу.
    public init(next: Node<TransportUrlRequest, Type>,
                etagHeaderKey: String = ETagConstants.eTagRequestHeaderKey) {
        self.next = next
        self.etagHeaderKey = etagHeaderKey
    }

    /// Пытается прочесть eTag-токен из хранилища и добавить его к запросу.
    /// В случае, если прочесть токен не удалось, то управление просто передается дальше.
    open override func process(_ data: TransportUrlRequest) -> Observer<Type> {
        guard let tag = UserDefaults.etagStorage?.value(forKey: data.url.absoluteString) as? String else {
            return next.process(data)
        }

        var headers = data.headers
        headers[self.etagHeaderKey] = tag

        let params = TransportUrlParameters(method: data.method,
                                            url: data.url,
                                            headers: headers)

        let newData = TransportUrlRequest(with: params, raw: data.raw)

        return next.process(newData)
    }

}
