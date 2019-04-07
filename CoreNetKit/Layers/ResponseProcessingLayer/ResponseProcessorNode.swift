//
//  RawJsonResponseProcessor.swift
//  CoreNetKitWithExample
//
//  Created by Александр Кравченков on 28/11/2018.
//  Copyright © 2018 Александр Кравченков. All rights reserved.
//

import Foundation
import Alamofire

/// Ошибки для `ResponseProcessorNode`
///
/// - rawResponseNotHaveMetaData: Возникает в случае, если запрос неконсистентен.
public enum ResponseProcessorNodeError: Error {
    case rawResponseNotHaveMetaData
}

/// Этот узел занимается первичной обработкой ответа сервера.
open class ResponseProcessorNode: Node<DataResponse<Data>, Json> {

    /// Следующий узел для обратки.
    public let next: ResponseProcessingLayerNode

    /// Инициаллизирует узел.
    ///
    /// - Parameter next: Следующий узел для обратки.
    public init(next: ResponseProcessingLayerNode) {
        self.next = next
    }

    /// Проверяет, возникла-ли какая-то ошибка во время работы.
    ///
    /// - Parameter data: Низкоуровневый ответ сервера.
    open override func process(_ data: DataResponse<Data>) -> Observer<Json> {

        switch data.result {
        case .failure(let error):

            guard let urlResponse = data.response, let urlRequest = data.request else {
                return .emit(error: error)
            }

            let response = UrlDataResponse(request: urlRequest,
                                           response: urlResponse,
                                           data: Data(), metrics: nil,
                                           serializationDuration: -1)

            return next.process(response)
        case .success(let val):

            guard let urlResponse = data.response, let urlRequest = data.request else {
                return Context<Json>()
                    .emit(error: ResponseProcessorNodeError.rawResponseNotHaveMetaData)
            }

            let dataResponse = UrlDataResponse(request: urlRequest,
                                               response: urlResponse,
                                               data: val,
                                               metrics: data.metrics,
                                               serializationDuration: data.serializationDuration)

            return self.next.process(dataResponse)
        }
    }
}
