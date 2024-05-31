//
//  RawJsonResponseProcessor.swift
//  CoreNetKitWithExample
//
//  Created by Александр Кравченков on 28/11/2018.
//  Copyright © 2018 Александр Кравченков. All rights reserved.
//

import Foundation

/// Errors for ``ResponseProcessorNode``
///
/// - rawResponseNotHaveMetaData: Occurs if the request is inconsistent.
public enum ResponseProcessorNodeError: Error {
    case rawResponseNotHaveMetaData
}

/// This node is responsible for the initial processing of the server response.
open class ResponseProcessorNode<Type>: AsyncNode {

    /// The next node for processing.
    public let next: any AsyncNode<URLDataResponse, Type>

    /// Initializer.
    ///
    /// - Parameter next: The next node for processing.
    public init(next: some AsyncNode<URLDataResponse, Type>) {
        self.next = next
    }

    /// Checks if there was any error during operation.
    ///
    /// - Parameter data: The low-level server response.
    open func process(
        _ data: NodeDataResponse,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<Type> {
        await .withCheckedCancellation {
            var log = Log(logViewObjectName, id: objectName, order: LogOrder.responseProcessorNode)

            switch data.result {
            case .failure(let error):
                log += "Catch URLSeesions error: \(error)" + .lineTabDeilimeter

                guard let urlResponse = data.urlResponse, let urlRequest = data.urlRequest else {
                    await logContext.add(log)
                    return .failure(error)
                }

                log += "Skip cause can extract parameters -> continue processing"

                let response = URLDataResponse(
                    request: urlRequest,
                    response: urlResponse,
                    data: Data()
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

                let dataResponse = URLDataResponse(
                    request: urlRequest,
                    response: urlResponse,
                    data: value
                )

                log += " --> \(urlResponse.statusCode)" + .lineTabDeilimeter
                log += String(data: value, encoding: .utf8) ?? "CURRUPTED"

                await logContext.add(log)
                return await next.process(dataResponse, logContext: logContext)
            }
        }
    }
}
