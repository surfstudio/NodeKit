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
        let request: TransportUrlRequest?

        let paramEncoding = { () -> ParameterEncoding in
            guard data.urlParameters.method == .get else {
                return data.encoding.raw
            }
            return URLEncoding.default
        }()

        if let jsonData = data.raw as? Json {
            do {
                request = try paramEncoding.encode(urlParameters: data.urlParameters, parameters: jsonData)
            } catch {
                return .emit(error: error)
            }
        } else if let bsonData = data.raw as? Bson {
            let body = data.urlParameters.method != .get ? bsonData.makeData() : nil
            request = TransportUrlRequest(with: data.urlParameters, raw: body)
        } else {
            request = nil
        }

        guard let unwrappedRequest = request else {
            return .emit(error: RequestEncodingError.unsupportedDataType)
        }

        return next.process(unwrappedRequest)
    }

}
