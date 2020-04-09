//
//  JsonNetworkReqestSenderNode.swift
//  CoreNetKitWithExample
//
//  Created by Александр Кравченков on 28/11/2018.
//  Copyright © 2018 Александр Кравченков. All rights reserved.
//

import Foundation
import Alamofire

public struct NodeDataResponse {
    public let urlResponse: HTTPURLResponse?
    public let urlRequest: URLRequest?
    public let result: Result<Data, Error>
}

/// Этот узел отправляет запрос на сервер и ожидает ответ.
/// - Important: этот узел имеет состояние (statefull)
open class RequestSenderNode<Type>: Node<URLRequest, Type>, Aborter {

    /// Тип для узла, который будет обрабатывать ответ от сервера.
    public typealias RawResponseProcessor = Node<NodeDataResponse, Type>

    /// Узел для обработки ответа.
    public var rawResponseProcessor: RawResponseProcessor

    /// Менеджер сессий
    private(set) var manager: URLSession

    private weak var task: URLSessionDataTask?
    private weak var context: Observer<NodeDataResponse>?

    /// Инициаллизирует узел.
    ///
    /// - Parameter rawResponseProcessor: Узел для обработки ответа.
    public init(rawResponseProcessor: RawResponseProcessor, manager: URLSession? = nil) {
        self.rawResponseProcessor = rawResponseProcessor
        self.manager = manager ?? ServerRequestsManager.shared.manager
    }

    /// Выполняет запрос,ожидает ответ и передает его следующему узлу.
    ///
    /// - Parameter data: Данные для исполнения запроса.
    open override func process(_ request: URLRequest) -> Observer<Type> {

        let context = Context<NodeDataResponse>()
        self.context = context

        var log = Log(self.logViewObjectName, id: self.objectName, order: LogOrder.requestSenderNode)

        self.task = manager.dataTask(with: request) { data, response, error in
            DispatchQueue.global(qos: .userInitiated).async {
                log += "Get response!)"
                let result: Result<Data, Error>

                if let error = error {
                    result = .failure(error)
                } else {
                    result = .success(data ?? Data())
                }

                let nodeResponse = NodeDataResponse(urlResponse: response as? HTTPURLResponse,
                                                    urlRequest: request,
                                                    result: result)
                context.log(log).emit(data: nodeResponse)
            }
        }
        log += "Request sended!"
        task?.resume()
        return context.map { self.rawResponseProcessor.process($0) }
    }

    /// Отменяет запрос.
    open func cancel() {
        self.context?.log?.add(message: "Request was cancelled!")
        self.task?.cancel()
        self.context?.cancel()
    }
}
