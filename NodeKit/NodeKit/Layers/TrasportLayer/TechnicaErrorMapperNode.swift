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
/// - dataNotAllowed: Возникает в случае, если вернулась системная ошибка 'kCFURLErrorDataNotAllowed' (предположительная причина - wifi нет, мобильный интернет в целом мог бы быть использован, но выключен. Доки apple крайне скудны в таких объяснениях)
/// - timeout: Возникает в случае, если превышен лимит ожидания ответа от сервера.
/// - cantConnectToHost: Возникает в случае, если не удалось установить соединение по конкретному адресу.
public enum BaseTechnicalError: Error {
    case noInternetConnection
    case dataNotAllowed
    case timeout
    case cantConnectToHost
}

/// Этот узел заниматеся маппингом технических ошибок
/// (ошибок уровня ОС)
/// - SeeAlso: `BaseTechnicalError`
open class TechnicaErrorMapperNode: AsyncNode {

    /// Следующий узел для обработки.
    open var next: any AsyncNode<URLRequest, Json>

    /// Инициаллизирует узел.
    ///
    /// - Parameter next: Следующий узел для обработки.
    public init(next: any AsyncNode<URLRequest, Json>) {
        self.next = next
    }

    /// Передает управление следующему узлу, и в случае ошибки маппит ее.
    ///
    /// - Parameter data: Данные для обработки.
    open func process(
        _ data: URLRequest,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<Json> {
        await .withCheckedCancellation {
            await next.process(data, logContext: logContext)
                .mapError { error in
                    switch (error as NSError).code {
                    case -1020:
                        return BaseTechnicalError.dataNotAllowed
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
}
