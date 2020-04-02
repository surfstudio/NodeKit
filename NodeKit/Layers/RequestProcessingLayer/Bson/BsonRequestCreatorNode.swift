//
//  BsonRequestCreatorNode.swift
//  NodeKit
//
//  Created by Vladislav Krupenko on 02.04.2020.
//  Copyright © 2020 Кравченков Александр. All rights reserved.
//

import Foundation
import Alamofire

open class BsonRequestCreatorNode<Output>: Node<TransportUrlBsonRequest, Output> {

    /// Следующий узел для обработки.
    public var next: Node<RawUrlRequest, Output>

    /// Провайдеры мета-данных
    public var providers: [MetadataProvider]

    /// Менеджер сессий
    private(set) var manager: Session

    /// Инициаллизирует узел.
    ///
    /// - Parameter next: Следующий узел для обработки.
    public init(next: Node<RawUrlRequest, Output>, providers: [MetadataProvider] = [], session: Session? = nil) {
        self.next = next
        self.providers = providers
        self.manager = session ?? ServerRequestsManager.shared.manager
    }

    /// Конфигурирует низкоуровненвый запрос.
    ///
    /// - Parameter data: Данные для конфигурирования и последующей отправки запроса.
    open override func process(_ data: TransportUrlBsonRequest) -> Observer<Output> {

        var mergedHeaders = data.headers

        self.providers.map { $0.metadata() }.forEach { dict in
            mergedHeaders.merge(dict, uniquingKeysWith: { $1 })
        }

        let request = manager.upload(data.raw.makeData(),
                                     to: data.url,
                                     method: data.method.http,
                                     headers: HTTPHeaders(mergedHeaders))

        return self.next.process(RawUrlRequest(dataRequest: request)).log(self.getLogMessage(data))
    }

    private func getLogMessage(_ data: TransportUrlBsonRequest) -> Log {
        var message = "<<<===\(self.objectName)===>>>\n"
        message += "input: \(type(of: data))\n\t"
        message += "method: \(data.method.http.rawValue)\n\t"
        message += "url: \(data.url.absoluteString)\n\t"
        message += "headers: \(data.headers)\n\t"
        message += "raw: \(data.raw)\n\t"

        return Log(message, id: self.objectName, order: LogOrder.requestCreatorNode)
    }

}
