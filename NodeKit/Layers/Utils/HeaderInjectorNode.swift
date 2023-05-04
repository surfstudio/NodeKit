//
//  HeaderInjectorNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 04/02/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation


/// Этот узел позволяет добавить любые хедеры в запрос.
open class HeaderInjectorNode<Type>: Node<TransportUrlRequest, Type> {

    /// Следующий в цепочке узел.
    public var next: Node<TransportUrlRequest, Type>

    /// Хедеры, которые необходимо добавить.
    public var headers: [String: String]

    /// Инициаллизирует узел.
    ///
    /// - Parameters:
    ///   - next: Следующий в цепочке узел.
    ///   - headers: Хедеры, которые необходимо добавить.
    public init(next: Node<TransportUrlRequest, Type>, headers: [String: String]) {
        self.next = next
        self.headers = headers
    }

    /// Добавляет хедеры к запросу и отправляет его слудующему в цепочке узлу.
    open override func process(_ data: TransportUrlRequest) -> Observer<Type> {
        var resultHeaders = self.headers
        var log = self.logViewObjectName
        log += "Add headers \(self.headers)" + .lineTabDeilimeter
        log += "To headers \(data.headers)" + .lineTabDeilimeter
        data.headers.forEach { resultHeaders[$0.key] = $0.value }
        let newData = TransportUrlRequest(method: data.method,
                                          url: data.url,
                                          headers: resultHeaders,
                                          raw: data.raw)
        log += "Result headers: \(resultHeaders)"
        return next.process(newData)
    }
}
