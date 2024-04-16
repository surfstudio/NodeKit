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
open class ResponseProcessorNode<Type>: AsyncNode {

    /// Следующий узел для обратки.
    public let next: any AsyncNode<UrlDataResponse, Type>

    /// Инициаллизирует узел.
    ///
    /// - Parameter next: Следующий узел для обратки.
    public init(next: some AsyncNode<UrlDataResponse, Type>) {
        self.next = next
    }

    /// Проверяет, возникла-ли какая-то ошибка во время работы.
    ///
    /// - Parameter data: Низкоуровневый ответ сервера.
    open func process(
        _ data: NodeDataResponse,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<Type> {
        var log = Log(logViewObjectName, id: objectName, order: LogOrder.responseProcessorNode)

        switch data.result {
        case .failure(let error):
            log += "Catch URLSeesions error: \(error)" + .lineTabDeilimeter

            guard let urlResponse = data.urlResponse, let urlRequest = data.urlRequest else {
                await logContext.add(log)
                return .failure(error)
            }

            log += "Skip cause can extract parameters -> continue processing"

            let response = UrlDataResponse(
                request: urlRequest,
                response: urlResponse,
                data: Data(),
                metrics: nil,
                serializationDuration: -1
            )

            log += "🌍 " + (urlRequest.httpMethod ?? "UNDEF") + " "
            log += urlRequest.url?.absoluteString ?? "UNDEF"
            log += " ~~> \(urlResponse.statusCode)" + .lineTabDeilimeter
            log += "EMPTY"

            await logContext.add(log)
            return await next.process(response, logContext: logContext)
        case .success(let value):
            log += "Request success!" + .lineTabDeilimeter
            
            guard
                let urlResponse = data.urlResponse,
                let urlRequest = data.urlRequest
            else {
                log += "But cant extract parameters -> terminate with error"
                await logContext.add(log)
                return .failure(ResponseProcessorNodeError.rawResponseNotHaveMetaData)
            }

            let dataResponse = UrlDataResponse(
                request: urlRequest,
                response: urlResponse,
                data: value,
                metrics: nil, // ?? почему nil
                serializationDuration: -1
            ) // почему -1?

            log += " --> \(urlResponse.statusCode)" + .lineTabDeilimeter
            log += String(data: value, encoding: .utf8) ?? "CURRUPTED"

            await logContext.add(log)
            return await next.process(dataResponse, logContext: logContext)
        }
    }
}
