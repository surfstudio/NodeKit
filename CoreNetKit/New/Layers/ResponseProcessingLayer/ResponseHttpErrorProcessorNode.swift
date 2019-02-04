//
//  ResponseHttpErrorProcessor.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 04/02/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

public enum ResponseHttpErrorProcessorNodeError: Error {
    case badRequest(Data)
    case internalServerError(Data)
    case unauthorized(Data)
    case forbidden(Data)
}

open class ResponseHttpErrorProcessorNode: Node<UrlDataResponse, Json> {

    public typealias HttpError = ResponseHttpErrorProcessorNodeError

    public var next: Node<UrlDataResponse, Json>

    public init(next: Node<UrlDataResponse, Json>) {
        self.next = next
    }

    open override func process(_ data: UrlDataResponse) -> Context<Json> {

        let context = Context<Json>()

        switch data.response.statusCode {
        case 400:
            return context.emit(error: HttpError.badRequest(data.data))
        case 401:
            return context.emit(error: HttpError.unauthorized(data.data))
        case 403:
            return context.emit(error: HttpError.forbidden(data.data))
        case 500:
            return context.emit(error: HttpError.internalServerError(data.data))
        default:
            break
        }

        return self.next.process(data)
    }
}
