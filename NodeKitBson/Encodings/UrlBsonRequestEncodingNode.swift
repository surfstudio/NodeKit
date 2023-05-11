//
//  UrlBsonRequestEncodingNode.swift
//  NodeKit
//
//  Created by Vladislav Krupenko on 06.05.2020.
//  Copyright © 2020 Кравченков Александр. All rights reserved.
//

import Foundation
import NodeKit

open class UrlBsonRequestEncodingNode<Type>: Node<RequestEncodingModel<Bson>, Type> {

    /// Следйющий узел для обработки.
    public var next: Node<TransportUrlRequest, Type>

    /// Инициаллизирует узел.
    ///
    /// - Parameters:
    ///   - next: Следйющий узел для обработки.
    public init(next: Node<TransportUrlRequest, Type>) {
        self.next = next
    }

    open override func process(_ data: RequestEncodingModel<Bson>) -> Observer<Type> {
        var log = getLogMessage(data)
        let body = data.urlParameters.method != .get ? data.raw.makeData() : nil
        let request = TransportUrlRequest(with: data.urlParameters, raw: body)
        log.message += "type: Bson"
        return next.process(request).log(log)
    }

}

// MARK: - Help Methods

private extension UrlBsonRequestEncodingNode {

    func getLogMessage(_ data: RequestEncodingModel<Bson>) -> Log {
        var message = "<<<===\(self.objectName)===>>>\n"
        message += "input: \(type(of: data))"
        message += "encoding: \(String(describing: data.encoding))"
        message += "raw: \(String(describing: data.raw))"
        return Log(message, id: self.objectName, order: LogOrder.requestEncodingNode)
    }

}
