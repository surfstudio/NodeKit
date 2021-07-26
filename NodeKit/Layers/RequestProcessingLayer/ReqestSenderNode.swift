//
//  JsonNetworkReqestSenderNode.swift
//  CoreNetKitWithExample
//
//  Created by Александр Кравченков on 28/11/2018.
//  Copyright © 2018 Александр Кравченков. All rights reserved.
//

import Foundation
import Alamofire

/// Этот узел отправляет запрос на сервер и ожидает ответ.
/// - Important: этот узел имеет состояние (statefull)
open class RequestSenderNode<Type>: Node<RawUrlRequest, Type>, Aborter {

    /// Тип для узла, который будет обрабатывать ответ от сервера.
    public typealias RawResponseProcessor = Node<DataResponse<Data, Error>, Type>

    /// Узел для обработки ответа.
    public var rawResponseProcessor: RawResponseProcessor

    private weak var request: DataRequest?
    private weak var context: Observer<DataResponse<Data, Error>>?

    /// Инициаллизирует узел.
    ///
    /// - Parameter rawResponseProcessor: Узел для обработки ответа.
    public init(rawResponseProcessor: RawResponseProcessor) {
        self.rawResponseProcessor = rawResponseProcessor
    }

    /// Выполняет запрос,ожидает ответ и передает его следующему узлу.
    ///
    /// - Parameter data: Данные для исполнения запроса.
    open override func process(_ data: RawUrlRequest) -> Observer<Type> {

        let context = Context<DataResponse<Data, Error>>()

        self.context = context
        var log = Log(self.logViewObjectName, id: self.objectName, order: LogOrder.requestSenderNode)
        self.request = data.dataRequest.responseData(queue: DispatchQueue.global(qos: .userInitiated)) { (response) in
            log += "Get response!)"
            switch response.result {
            case .failure(let error):
                context.log(log).emit(error: error)
            case .success:
                let dataResponse = DataResponse<Data, Error>(
                    request: response.request,
                    response: response.response,
                    data: response.data,
                    metrics: response.metrics,
                    serializationDuration: response.serializationDuration,
                    result: response.result.mapError { $0 }
                )
                context.log(log).emit(data: dataResponse)
            }
        }
        log += "Request sended!"
        return context.map { self.rawResponseProcessor.process($0) }
    }

    /// Отменяет запрос.
    open func cancel() {
        self.context?.log?.add(message: "Request was cancelled!")
        self.request?.cancel()
        self.context?.cancel()
    }
}
