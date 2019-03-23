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
open class ResponseHttpErrorProcessorNode: ResponseProcessingLayerNode {

    public typealias HttpError = ResponseHttpErrorProcessorNodeError

    /// Следующий узел для обработки.
    public var next: ResponseProcessingLayerNode

    /// Инициаллизирует объект.
    ///
    /// - Parameter next: Следующий узел для обработки.
    public init(next: ResponseProcessingLayerNode) {
        self.next = next
    }

    /// Сопосотавляет HTTP-коды с заданными и в случае их несовпадения передает управление дальше.
    /// В противном случае возвращает `HttpError`
    ///
    /// - Parameter data: Модель ответа сервера.
    open override func process(_ data: UrlDataResponse) -> Observer<Json> {

        let context = Context<Json>()

        switch data.response.statusCode {
        case 400:
            return context.emit(error: HttpError.badRequest(data.data))
        case 401:
            return context.emit(error: HttpError.unauthorized(data.data))
        case 403:
            return context.emit(error: HttpError.forbidden(data.data))
        case 404:
            return context.emit(error: HttpError.notFound)
        case 500:
            return context.emit(error: HttpError.internalServerError(data.data))
        default:
            break
        }

        return self.next.process(data)
    }
}
