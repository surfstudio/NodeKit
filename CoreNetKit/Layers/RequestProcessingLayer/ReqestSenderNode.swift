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
open class RequestSenderNode: Node<RawUrlRequest, Json>, Aborter {

    /// Тип для узла, который будет обрабатывать ответ от сервера.
    public typealias RawResponseProcessor = Node<DataResponse<Data>, Json>

    /// Узел для обработки ответа.
    public var rawResponseProcessor: RawResponseProcessor

    private weak var request: DataRequest?
    private weak var context: Observer<DataResponse<Data>>?

    /// Инициаллизирует узел.
    ///
    /// - Parameter rawResponseProcessor: Узел для обработки ответа.
    public init(rawResponseProcessor: RawResponseProcessor) {
        self.rawResponseProcessor = rawResponseProcessor
    }

    /// Выполняет запрос,ожидает ответ и передает его следующему узлу.
    ///
    /// - Parameter data: Данные для исполнения запроса.
    open override func process(_ data: RawUrlRequest) -> Observer<Json> {

        let context = Context<DataResponse<Data>>()

        self.context = context

        self.request = data.dataRequest.responseData(queue: DispatchQueue.global(qos: .userInitiated)) { (response) in
            context.emit(data: response)
        }

        return context.flatMap { self.rawResponseProcessor.process($0) }
    }

    /// Отменяет запрос.
    open func cancel() {
        self.request?.cancel()
        self.context?.cancel()
    }
}
