//
//  UrlJsonRequestEncodingNode.swift
//  NodeKit
//
//  Created by Vladislav Krupenko on 06.05.2020.
//  Copyright © 2020 Кравченков Александр. All rights reserved.
//

import Foundation

@available(iOS 13.0, *)
open class UrlJsonRequestEncodingNode<Type>: Node<RequestEncodingModel, Type> {

    /// Следующий узел для обработки.
    public var next: Node<TransportUrlRequest, Type>

    /// Инициаллизирует узел.
    ///
    /// - Parameters:
    ///   - next: Следйющий узел для обработки.
    public init(next: Node<TransportUrlRequest, Type>) {
        self.next = next
    }

    open override func process(_ data: RequestEncodingModel) async -> Result<Type, Error> {
        let paramEncoding = parameterEncoding(from: data)
        return await .withMappedExceptions(RequestEncodingError.unsupportedDataType) {
            guard let encoding = paramEncoding else {
                return .failure(RequestEncodingNodeError.missedJsonEncodingType)
            }
            let request = try encoding.encode(urlParameters: data.urlParameters, parameters: data.raw)
            return await next.process(request)
        }
    }

    private func parameterEncoding(from data: RequestEncodingModel) -> ParameterEncoding? {
        guard data.urlParameters.method == .get else {
            return data.encoding?.raw
        }
        return URLEncoding.default
    }

}

// MARK: - Help Methods

@available(iOS 13.0, *)
private extension UrlJsonRequestEncodingNode {

    func getLogMessage(_ data: RequestEncodingModel) -> Log {
        var message = "<<<===\(self.objectName)===>>>\n"
        message += "input: \(type(of: data))"
        message += "encoding: \(String(describing: data.encoding))"
        message += "raw: \(String(describing: data.raw))"
        return Log(message, id: self.objectName, order: LogOrder.requestEncodingNode)
    }

}
