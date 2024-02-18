//
//  JsonNetworkReqestSenderNode.swift
//  CoreNetKitWithExample
//
//  Created by Александр Кравченков on 28/11/2018.
//  Copyright © 2018 Александр Кравченков. All rights reserved.
//

import Foundation

public struct NodeDataResponse {
     public let urlResponse: HTTPURLResponse?
     public let urlRequest: URLRequest?
     public let result: Result<Data, Error>
 }

/// Этот узел отправляет запрос на сервер и ожидает ответ.
/// - Important: этот узел имеет состояние (statefull)
@available(iOS 13.0, *)
open class RequestSenderNode<Type>: Node<URLRequest, Type>, Aborter {

    /// Тип для узла, который будет обрабатывать ответ от сервера.
    public typealias RawResponseProcessor = Node<NodeDataResponse, Type>

    /// Узел для обработки ответа.
    public var rawResponseProcessor: RawResponseProcessor

    /// Менеджер сессий
    private(set) var manager: URLSession

    private var responseQueue: DispatchQueue

    private weak var task: URLSessionDataTask?
    private weak var context: Observer<NodeDataResponse>?

    /// Инициаллизирует узел.
    ///
    /// - Parameter rawResponseProcessor: Узел для обработки ответа.
    /// - Parameter responseQueue: Очередь, на которой будет выполнен ответ
    /// - Parameter manager: URLSession менеджер, по умолчанию задается сессия из ServerRequestsManager
    public init(
        rawResponseProcessor: RawResponseProcessor,
        responseQueue: DispatchQueue,
        manager: URLSession? = nil
    ) {
        self.rawResponseProcessor = rawResponseProcessor
        self.responseQueue = responseQueue
        self.manager = manager ?? ServerRequestsManager.shared.manager
    }

    /// Выполняет запрос,ожидает ответ и передает его следующему узлу.
    ///
    /// - Parameter request: Данные для исполнения запроса.
    open override func process(_ request: URLRequest) async -> Result<Type, Error> {
        async let nodeResponse = nodeResponse(request)
        return await rawResponseProcessor.process(nodeResponse)
    }

    private func nodeResponse(_ request: URLRequest) async -> NodeDataResponse {
        return await withCheckedContinuation { continuation in
            manager.dataTask(with: request) { data, response, error in
                let result: Result<Data, Error>
                if let error = error {
                    result = .failure(error)
                } else {
                    result = .success(data ?? Data())
                }
                let nodeResponse = NodeDataResponse(
                    urlResponse: response as? HTTPURLResponse,
                    urlRequest: request,
                    result: result
                )
                continuation.resume(with: .success(nodeResponse))
            }
        }
    }

    /// Отменяет запрос.
    open func cancel() {
        self.context?.log?.add(message: "Request was cancelled!")
        self.task?.cancel()
        self.context?.cancel()
    }

}
