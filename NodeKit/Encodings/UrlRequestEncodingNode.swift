//
//  UrlRequestEncodingNode.swift
//  NodeKit
//
//  Created by Vladislav Krupenko on 10.04.2020.
//  Copyright © 2020 Кравченков Александр. All rights reserved.
//

import Foundation

enum RequestEncodingNodeError: Error {
    case unsupportedDataType
    case missedJsonEncodingType
}

open class UrlRequestEncodingNode<Raw, Type>: Node<RequestEncodingModel<Raw>, Type> {

    /// Следйющий узел для обработки.
    public var next: Node<TransportUrlRequest, Type>

    /// Инициаллизирует узел.
    ///
    /// - Parameters:
    ///   - next: Следйющий узел для обработки.
    public init(next: Node<TransportUrlRequest, Type>) {
        self.next = next
    }

    open override func process(_ data: RequestEncodingModel<Raw>) -> Observer<Type> {
        switch data {
        case let data as RequestEncodingModel<Json>:
            return UrlJsonRequestEncodingNode(next: next).process(data)
        case let data as RequestEncodingModel<Bson>:
            return UrlBsonRequestEncodingNode(next: next).process(data)
        default:
            let message = "Unsupported data type -> terminate with error"
            let log = Log(message, id: self.objectName, order: LogOrder.requestEncodingNode)
            return Context<Type>().log(log).emit(error: RequestEncodingNodeError.unsupportedDataType)
        }
    }

}
