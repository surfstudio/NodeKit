//  CustomServerErrorProcessorNode.swift
//  IntegrationTests
//
//  Created by Vladislav Krupenko on 03.04.2020.
//  Copyright © 2020 Кравченков Александр. All rights reserved.
//
import Foundation

@testable
import NodeKit

/// HTTP ошибки.
///
/// - badRequest: 400-HTTP код ответа.
/// - unauthorized: 401 HTTP-код ответа.
/// - forbidden: 403 HTTP-код ответа.
/// - notFound: 404 HTTP-код ответа.
/// - internalServerError: 500 HTTP-код ответа.
public enum CustomServerProcessorNodeError: Error {
    case userExist
}

/// Этот узел обрабатывает ответ сервера и в случае статус кодов,
/// которые соответствуют ошибкам, перечисленным в `ResponseHttpErrorProcessorNodeError`
/// В случае, если коды не совпали в необходимыми,то управление переходит следующему узлу.
open class CustomServerErrorProcessorNode<Type>: Node<UrlDataResponse, Type> {

    public typealias ServerError = CustomServerProcessorNodeError

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

        let context = Context<Type>()

        switch data.response.statusCode {
        case 409:
            return context.emit(error: ServerError.userExist)
        default:
            break
        }
        let log = self.logViewObjectName + "Cant match status code -> call next"
        return self.next.process(data).log(Log(log, id: self.objectName, order: LogOrder.responseHttpErrorProcessorNode))
    }

}
