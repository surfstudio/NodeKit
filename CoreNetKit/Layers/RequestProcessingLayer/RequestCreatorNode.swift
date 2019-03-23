//
//  RequestSenderNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 18/12/2018.
//  Copyright © 2018 Кравченков Александр. All rights reserved.
//

import Foundation
import Alamofire

/// Этот узел инициаллизирует URL запрос.
open class RequestCreatorNode: Node<TransportUrlRequest, Json> {

    /// Следующий узел для обработки.
    public var next: RequestProcessingLayerNode

    /// Инициаллизирует узел.
    ///
    /// - Parameter next: Следующий узел для обработки.
    public init(next: RequestProcessingLayerNode) {
        self.next = next
    }

    /// Конфигурирует низкоуровненвый запрос.
    ///
    /// - Parameter data: Данные для конфигурирования и последующей отправки запроса.
    open override func process(_ data: TransportUrlRequest) -> Observer<Json> {
        let manager = ServerRequestsManager.shared.manager

        let paramEncoding = {() -> ParameterEncoding in
            if data.method == .get {
                return URLEncoding.default
            }
            return data.parametersEncoding.raw
        }()

        let request = manager.request(
            data.url,
            method: data.method.http,
            parameters: data.raw,
            encoding: paramEncoding,
            headers: data.headers
        )

        return self.next.process(RawUrlRequest(dataRequest: request))
    }
}
