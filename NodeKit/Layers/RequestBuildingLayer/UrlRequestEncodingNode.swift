//
//  UrlRequestEncodingNode.swift
//  NodeKit
//
//  Created by Vladislav Krupenko on 10.04.2020.
//  Copyright © 2020 Кравченков Александр. All rights reserved.
//

import Foundation
import Alamofire

enum RequestEncodingNodeError: Error {
    case unsupportedDataType
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
        var log = getLogMessage(data)
        let request: TransportUrlRequest?

        let paramEncoding = { () -> ParameterEncoding? in
            guard data.urlParameters.method == .get else {
                return data.encoding?.raw
            }
            return URLEncoding.default
        }()

        if let jsonData = data.raw as? Json, let encoding = paramEncoding {
            do {
                request = try encoding.encode(urlParameters: data.urlParameters, parameters: jsonData)
                log.message += "type: Json"
            } catch {
                log += "But cant encode data -> terminate with error"
                return Context<Type>().log(log).emit(error: RequestEncodingError.unsupportedDataType)
            }
        } else if let bsonData = data.raw as? Bson {
            let body = data.urlParameters.method != .get ? bsonData.makeData() : nil
            request = TransportUrlRequest(with: data.urlParameters, raw: body)
            log.message += "type: Bson"
        } else {
            request = nil
            log.message += "type: Unsupported"
        }

        guard let unwrappedRequest = request else {
            log += "Unsupported data type -> terminate with error"
            return Context<Type>().log(log).emit(error: RequestEncodingError.unsupportedDataType)
        }

        return next.process(unwrappedRequest).log(log)
    }

}

// MARK: - Help Methods

private extension UrlRequestEncodingNode {

    func getLogMessage(_ data: RequestEncodingModel<Raw>) -> Log {
        var message = "<<<===\(self.objectName)===>>>\n"
        message += "input: \(type(of: data))"
        message += "encoding: \(data.encoding)"
        message += "raw: \(String(describing: data.raw))"
        return Log(message, id: self.objectName, order: LogOrder.requestEncodingNode)
    }

}
