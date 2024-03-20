//
//  RequestRouterNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 05/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// Этот узел добавляет маршрут к создаваемому запросу.
/// - SeeAlso:
///     - `RequestModel`
///     - `RoutableRequestModel`
///     - `Node`
///     - `MetadataConnectorNode`
///     - `RequstEncoderNode`
open class RequestRouterNode<Raw, Route, Output>: Node {

    /// Тип для следующего узла.
    public typealias NextNode = Node<RoutableRequestModel<Route, Raw>, Output>

    /// Следующий узел для обработки.
    public var next: any NextNode

    /// Маршрут для запроса.
    public var route: Route

    /// Инициаллизирует узел
    ///
    /// - Parameters:
    ///   - next: Следующий узел для обработки.
    ///   - route: Маршрут для запроса.
    public init(next: any NextNode, route: Route) {
        self.next = next
        self.route = route
    }

    /// Преобразует `RequestModel` в `RoutableRequestModel` и передает управление следующему узлу
    open func process(_ data: RequestModel<Raw>) -> Observer<Output> {
        return self.next.process(RoutableRequestModel(metadata: data.metadata, raw: data.raw, route: self.route))
    }

    /// Преобразует `RequestModel` в `RoutableRequestModel` и передает управление следующему узлу
    open func process(
        _ data: RequestModel<Raw>,
        logContext: LoggingContextProtocol
    ) async -> Result<Output, Error> {
        return await next.process(
            RoutableRequestModel(metadata: data.metadata, raw: data.raw, route: route),
            logContext: logContext
        )
    }
}
