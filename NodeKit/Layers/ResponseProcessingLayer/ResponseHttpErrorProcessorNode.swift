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
open class ResponseHttpErrorProcessorNode<Type>: Node<UrlDataResponse, Type> {

    public typealias HttpError = ResponseHttpErrorProcessorNodeError

    /// Следующий узел для обработки.
    public var next: Node<UrlDataResponse, Type>

    /// Инициаллизирует объект.
    ///
    /// - Parameter next: Следующий узел для обработки.
    public init(next: Node<UrlDataResponse, Type>) {
        self.next = next
    }

    /// Сопосотавляет HTTP-коды с заданными и в случае их несовпадения передает управление дальше.
    /// В противном случае возвращает `HttpError`
    ///
    /// - Parameter data: Модель ответа сервера.
    open override func process(_ data: UrlDataResponse) -> Observer<Type> {

        guard let error = self.mapError(by: data) else {
            let log = self.logViewObjectName + "Cant match status code -> call next"
            return self.next.process(data).log(Log(log, id: self.objectName, order: LogOrder.responseHttpErrorProcessorNode))
        }

        return .emit(error: error)
    }

    @available(iOS 13.0, *)
    open override func make(_ data: UrlDataResponse) -> PublisherContext<Type> {
        guard let error = self.mapError(by: data) else {
            let log = self.logViewObjectName + "Cant match status code -> call next"
            return self.next.make(data).log(Log(log, id: self.objectName, order: LogOrder.responseHttpErrorProcessorNode))
        }

        return .emit(error: error)
    }

    open func mapError(by data: UrlDataResponse) -> Error? {
        switch data.response.statusCode {
        case 400:
            return HttpError.badRequest(data.data)
        case 401:
            return HttpError.unauthorized(data.data)
        case 403:
            return HttpError.forbidden(data.data)
        case 404:
            return HttpError.notFound
        case 500:
            return HttpError.internalServerError(data.data)
        default:
            return nil
        }
    }
}
