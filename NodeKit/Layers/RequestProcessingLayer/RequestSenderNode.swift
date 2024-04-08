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
open class RequestSenderNode<Type>: AsyncNode, Aborter {

    /// Тип для узла, который будет обрабатывать ответ от сервера.
    public typealias RawResponseProcessor = AsyncNode<NodeDataResponse, Type>

    /// Узел для обработки ответа.
    public var rawResponseProcessor: any RawResponseProcessor

    /// Менеджер сессий
    private(set) var manager: URLSession
    private let dataTaskActor: URLSessionDataTaskActorProtocol

    /// Инициаллизирует узел.
    ///
    /// - Parameter rawResponseProcessor: Узел для обработки ответа.
    /// - Parameter responseQueue: Очередь, на которой будет выполнен ответ
    /// - Parameter manager: URLSession менеджер, по умолчанию задается сессия из ServerRequestsManager
    public init(
        rawResponseProcessor: some RawResponseProcessor,
        dataTaskActor: URLSessionDataTaskActorProtocol? = nil,
        manager: URLSession? = nil
    ) {
        self.rawResponseProcessor = rawResponseProcessor
        self.dataTaskActor = dataTaskActor ?? URLSessionDataTaskActor()
        self.manager = manager ?? ServerRequestsManager.shared.manager
    }

    /// Выполняет запрос,ожидает ответ и передает его следующему узлу.
    ///
    /// - Parameter request: Данные для исполнения запроса.
    open func process(
        _ request: URLRequest,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<Type> {
        var log = Log(logViewObjectName, id: objectName, order: LogOrder.requestSenderNode)
        
        async let nodeResponse = nodeResponse(request, logContext: logContext)
        
        log += "Request sended!"
        
        let response = await nodeResponse
        
        log += "Get response!)"
        
        let result = await rawResponseProcessor.process(response, logContext: logContext)

        await logContext.add(log)
        return result
    }

    open func cancel(logContext: LoggingContextProtocol) {
        let log = Log(
            logViewObjectName + "Request was cancelled!",
            id: objectName,
            order: LogOrder.requestSenderNode
        )
        Task.detached { [weak self] in
            await logContext.add(log)
            await self?.dataTaskActor.cancelTask()
        }
    }

    // MARK: - Private Methods

    private func nodeResponse(
        _ request: URLRequest,
        logContext: LoggingContextProtocol
    ) async -> NodeDataResponse {
        return await withCheckedContinuation { continuation in
            let task = manager.dataTask(with: request) { data, response, error in
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
            task.resume()
            Task {
                await dataTaskActor.store(task: task)
            }
        }
    }

}
