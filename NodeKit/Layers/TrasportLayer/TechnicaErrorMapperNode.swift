//
//  TechnicaErrorMapperNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 12/02/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// Ошибки для узла `TechnicaErrorMapperNode`
///
/// - noInternetConnection: Возникает в случае, если вернулась системная ошибка об отсутствии соединения.
/// - timeout: Возникает в случае, если превышен лимит ожидания ответа от сервера.
/// - cantConnectToHost: Возникает в случае, если не удалось установить соединение по конкретному адресу.
public enum BaseTechnicalError: Error {
    case noInternetConnection
    case timeout
    case cantConnectToHost
}

/// Этот узел заниматеся маппингом технических ошибок
/// (ошибок уровня ОС)
/// - SeeAlso: `BaseTechnicalError`
open class TechnicaErrorMapperNode<Type>: Node<URLRequest, Type> {

    /// Следующий узел для обработки.
    open var next: Node<URLRequest, Type>

    /// Инициаллизирует узел.
    ///
    /// - Parameter next: Следующий узел для обработки.
    public init(next: Node<URLRequest, Type>) {
        self.next = next
    }

    /// Передает управление следующему узлу, и в случае ошибки маппит ее.
    ///
    /// - Parameter data: Данные для обработки.
    open override func process(_ data: URLRequest) -> Observer<Type> {
        return self.next.process(data)
            .mapError { error -> Error in
                switch (error as NSError).code {
                case -1009:
                    return BaseTechnicalError.noInternetConnection
                case -1001:
                    return BaseTechnicalError.timeout
                case -1004:
                    return BaseTechnicalError.cantConnectToHost
                default:
                    return error
                }
            }
    }
}

