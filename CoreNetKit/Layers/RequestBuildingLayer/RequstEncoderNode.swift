//
//  RequstEncoderNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 05/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// Этот узел добавляет кодировку к создаваемому запросу.
/// - SeeAlso:
///     - ``
///     - `RequestModel`
///     - `RoutableRequestModel`
///     - `Node`
///     - `RequestRouterNode`
///     - `EncodableRequestModel`
///     - `UrlRequestTrasformatorNode`
open class RequstEncoderNode<Raw, Route, Encoding, Output>: RequestRouterNode<Raw, Route, Output>.NextNode {

    /// Тип для следюущего узла.
    public typealias NextNode = Node<EncodableRequestModel<Route, Raw, Encoding>, Output>

    /// Следюущий узел для обработки.
    public var next: NextNode

    /// Кодировка для запроса.
    public var encoding: Encoding

    /// Инициаллизирует узел.
    ///
    /// - Parameters:
    ///   - next: Следюущий узел для обработки.
    ///   - encoding: Кодировка для запроса.
    public init(next: NextNode, encoding: Encoding) {
        self.next = next
        self.encoding = encoding
    }

    /// Преобразует `RoutableRequestModel` в `EncodableRequestModel`
    /// и передает управление следующему узлу.
    open override func process(_ data: RoutableRequestModel<Route, Raw>) -> Observer<Output> {
        let model = EncodableRequestModel(metadata: data.metadata, raw: data.raw, route: data.route, encoding: self.encoding)
        return self.next.process(model)
    }
}
