//
//  UrlJsonRequestEncodingNode.swift
//  NodeKit
//
//  Created by Vladislav Krupenko on 06.05.2020.
//  Copyright © 2020 Кравченков Александр. All rights reserved.
//

import Foundation

open class UrlJsonRequestEncodingNode<Type>: Node<RequestEncodingModel<Json>, Type> {

    /// Следующий узел для обработки.
    public var next: Node<TransportUrlRequest, Type>

    /// Инициаллизирует узел.
    ///
    /// - Parameters:
    ///   - next: Следйющий узел для обработки.
    public init(next: Node<TransportUrlRequest, Type>) {
        self.next = next
    }

    open override func process(_ data: RequestEncodingModel<Json>) -> Observer<Type> {
        var log = getLogMessage(data)
        let request: TransportUrlRequest?
        let paramEncoding = { () -> ParameterEncoding? in
            guard data.urlParameters.method == .get else {
                return data.encoding?.raw
            }
            return URLEncoding.default
        }()
        guard let encoding = paramEncoding else {
            log += "Missed encoding type -> terminate with error"
            return Context<Type>().log(log).emit(error: RequestEncodingNodeError.missedJsonEncodingType)
        }
        do {
            request = try encoding.encode(urlParameters: data.urlParameters, parameters: data.raw)
            log.message += "type: Json"
        } catch {
            log += "But can't encode data -> terminate with error"
            return Context<Type>().log(log).emit(error: RequestEncodingError.unsupportedDataType)
        }

        guard let unwrappedRequest = request else {
            log += "Unsupported data type -> terminate with error"
            return Context<Type>().log(log).emit(error: RequestEncodingError.unsupportedDataType)
        }

        return next.process(unwrappedRequest).log(log)
    }

}

// MARK: - Help Methods

private extension UrlJsonRequestEncodingNode {

    func getLogMessage(_ data: RequestEncodingModel<Json>) -> Log {
        var message = "<<<===\(self.objectName)===>>>\n"
        message += "input: \(type(of: data))"
        message += "encoding: \(String(describing: data.encoding))"
        message += "raw: \(String(describing: data.raw))"
        return Log(message, id: self.objectName, order: LogOrder.requestEncodingNode)
    }

}
