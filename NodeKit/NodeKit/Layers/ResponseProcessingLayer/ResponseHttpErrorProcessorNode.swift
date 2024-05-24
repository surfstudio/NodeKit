//
//  ResponseHttpErrorProcessor.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 04/02/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// HTTP ошибки.
///
/// - badRequest: 400-HTTP код ответа.
/// - unauthorized: 401 HTTP-код ответа.
/// - forbidden: 403 HTTP-код ответа.
/// - notFound: 404 HTTP-код ответа.
/// - internalServerError: 500 HTTP-код ответа.
public enum ResponseHttpErrorProcessorNodeError: Error {
    case badRequest(Data)
    case unauthorized(Data)
    case forbidden(Data)
    case notFound
    case internalServerError(Data)
}

/// Этот узел обрабатывает ответ сервера и в случае статус кодов,
/// которые соответствуют ошибкам, перечисленным в `ResponseHttpErrorProcessorNodeError`
/// В случае, если коды не совпали в необходимыми,то управление переходит следующему узлу.
open class ResponseHttpErrorProcessorNode<Type>: AsyncNode {

    public typealias HttpError = ResponseHttpErrorProcessorNodeError

    /// Следующий узел для обработки.
    public var next: any AsyncNode<URLDataResponse, Type>

    /// Инициаллизирует объект.
    ///
    /// - Parameter next: Следующий узел для обработки.
    public init(next: some AsyncNode<URLDataResponse, Type>) {
        self.next = next
    }

    /// Сопоставляет HTTP-коды с заданными и в случае их несовпадения передает управление дальше.
    /// В противном случае возвращает `HttpError`
    ///
    /// - Parameter data: Модель ответа сервера.
    open func process(
        _ data: URLDataResponse,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<Type> {
        await .withCheckedCancellation {
            switch data.response.statusCode {
            case 400:
                return .failure(HttpError.badRequest(data.data))
            case 401:
                return .failure(HttpError.unauthorized(data.data))
            case 403:
                return .failure(HttpError.forbidden(data.data))
            case 404:
                return .failure(HttpError.notFound)
            case 500:
                return .failure(HttpError.internalServerError(data.data))
            default:
                break
            }
            let log = Log(logViewObjectName + "Cant match status code -> call next", id: objectName)
            await logContext.add(log)
            return await next.process(data, logContext: logContext)
        }
    }
}
