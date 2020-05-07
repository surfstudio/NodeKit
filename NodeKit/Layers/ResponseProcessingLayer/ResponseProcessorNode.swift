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
    open override func process(_ data: NodeDataResponse) -> Observer<Type> {
        var log = Log(self.logViewObjectName, id: self.objectName, order: LogOrder.responseProcessorNode)

        switch data.result {
        case .failure(let error):
            log += "Catch URLSeesions error: \(error)" + .lineTabDeilimeter

            guard let urlResponse = data.urlResponse, let urlRequest = data.urlRequest else {
                return Context<Type>().log(log).emit(error: error)
            }
            log += "Skip cause can extract parameters -> continue processing"

            let response = UrlDataResponse(request: urlRequest,
                                           response: urlResponse,
                                           data: Data(),
                                           metrics: nil,
                                           serializationDuration: -1)
//            log += "🌍 " + (urlRequest.method?.rawValue ?? "UNDEF") + " " + (urlRequest.url?.absoluteString ?? "UNDEF")
            log += " ~~> \(urlResponse.statusCode)" + .lineTabDeilimeter
            log += "EMPTY"

            return next.process(response).log(log)
        case .success(let value):
            log += "Request success!" + .lineTabDeilimeter

            guard let urlResponse = data.urlResponse, let urlRequest = data.urlRequest else {
                log += "But cant extract parameters -> terminate with error"
                return Context<Type>()
                    .log(log)
                    .emit(error: ResponseProcessorNodeError.rawResponseNotHaveMetaData)
            }
            let dataResponse = UrlDataResponse(request: urlRequest,
                                               response: urlResponse,
                                               data: value,
                                               metrics: nil,
                                               serializationDuration: -1)

//            log += "🌍 " + (urlRequest.method?.rawValue ?? "UNDEF") + " " + (urlRequest.url?.absoluteString ?? "UNDEF")
            log += " --> \(urlResponse.statusCode)" + .lineTabDeilimeter
            log += String(data: value, encoding: .utf8) ?? "CURRUPTED"

            return self.next.process(dataResponse).log(log)
        }
    }
}
