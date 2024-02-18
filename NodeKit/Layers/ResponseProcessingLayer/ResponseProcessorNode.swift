//
//  RawJsonResponseProcessor.swift
//  CoreNetKitWithExample
//
//  Created by Александр Кравченков on 28/11/2018.
//  Copyright © 2018 Александр Кравченков. All rights reserved.
//

import Foundation

/// Ошибки для `ResponseProcessorNode`
///
/// - rawResponseNotHaveMetaData: Возникает в случае, если запрос неконсистентен.
public enum ResponseProcessorNodeError: Error {
    case rawResponseNotHaveMetaData
}

/// Этот узел занимается первичной обработкой ответа сервера.
open class ResponseProcessorNode<Type>: Node<NodeDataResponse, Type> {

    /// Следующий узел для обратки.
    public let next: Node<UrlDataResponse, Type>

    /// Инициаллизирует узел.
    ///
    /// - Parameter next: Следующий узел для обратки.
    public init(next: Node<UrlDataResponse, Type>) {
        self.next = next
    }

    /// Проверяет, возникла-ли какая-то ошибка во время работы.
    ///
    /// - Parameter data: Низкоуровневый ответ сервера.
    open override func process(_ data: NodeDataResponse) async -> Result<Type, Error> {
        switch data.result {
        case .failure(let error):
            guard let urlResponse = data.urlResponse, let urlRequest = data.urlRequest else {
                return .failure(error)
            }
            let response = UrlDataResponse(
                request: urlRequest,
                response: urlResponse,
                data: Data(),
                metrics: nil,
                serializationDuration: -1
            )
            return await next.process(response)
        case .success(let value):
            guard
                let urlResponse = data.urlResponse,
                let urlRequest = data.urlRequest
            else {
                return .failure(ResponseProcessorNodeError.rawResponseNotHaveMetaData)
            }

            let dataResponse = UrlDataResponse(
                request: urlRequest,
                response: urlResponse,
                data: value,
                metrics: nil, // ?? почему nil
                serializationDuration: -1 // почему -1?
            )
            return await next.process(dataResponse)
        }
    }
}
