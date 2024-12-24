//
//  ResponseHttpErrorProcessor.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 04/02/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// HTTP errors.
///
/// - badRequest: 400 - HTTP response code.
/// - unauthorized: 401 - HTTP response code.
/// - forbidden: 403 - HTTP response code.
/// - notFound: 404 - HTTP response code.
/// - internalServerError: 500 - HTTP response code.
public enum ResponseHttpErrorProcessorNodeError: Error {
    case badRequest(Data)
    case unauthorized(Data)
    case forbidden(Data)
    case notFound
    case internalServerError(Data)
}

/// This node processes the server response and in case of status codes 
/// that correspond to errors listed in ``ResponseHttpErrorProcessorNodeError``,
/// if the codes do not match the required ones, control is passed to the next node.
open class ResponseHttpErrorProcessorNode<Type>: AsyncNode {

    public typealias HttpError = ResponseHttpErrorProcessorNodeError

    /// The next node for processing.
    public var next: any AsyncNode<URLDataResponse, Type>

    /// Initializer.
    ///
    /// - Parameter next: The next node for processing.
    public init(next: some AsyncNode<URLDataResponse, Type>) {
        self.next = next
    }

    /// Matches HTTP codes with the specified ones and passes control further in case of mismatch. 
    /// Otherwise, returns `HttpError`.
    ///
    /// - Parameter data: The server response model.
    open func process(
        _ data: URLDataResponse,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<Type> {
        await .withCheckedCancellation {
            switch data.response.statusCode {
            case 400:
                let log = LogChain(
                    "Match with 400 status code (badRequest)",
                    id: objectName,
                    logType: .failure,
                    order: LogOrder.responseHttpErrorProcessorNode
                )
                await logContext.add(log)
                return .failure(HttpError.badRequest(data.data))
            case 401:
                let log = LogChain(
                    "Match with 401 status code (unauthorized)",
                    id: objectName,
                    logType: .failure,
                    order: LogOrder.responseHttpErrorProcessorNode
                )
                await logContext.add(log)
                return .failure(HttpError.unauthorized(data.data))
            case 403:
                let log = LogChain(
                    "Match with 403 status code (forbidden)",
                    id: objectName,
                    logType: .failure,
                    order: LogOrder.responseHttpErrorProcessorNode
                )
                await logContext.add(log)
                return .failure(HttpError.forbidden(data.data))
            case 404:
                let log = LogChain(
                    "Match with 404 status code (notFound)",
                    id: objectName,
                    logType: .failure,
                    order: LogOrder.responseHttpErrorProcessorNode
                )
                await logContext.add(log)
                return .failure(HttpError.notFound)
            case 500:
                let log = LogChain(
                    "Match with 500 status code (internalServerError)",
                    id: objectName,
                    logType: .failure,
                    order: LogOrder.responseHttpErrorProcessorNode
                )
                await logContext.add(log)
                return .failure(HttpError.internalServerError(data.data))
            default:
                break
            }
            let log = LogChain(
                "Cant match status code -> call next",
                id: objectName,
                logType: .info,
                order: LogOrder.responseHttpErrorProcessorNode
            )
            await logContext.add(log)
            return await next.process(data, logContext: logContext)
        }
    }
}
