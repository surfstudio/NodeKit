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

/// This node sends a request to the server and waits for a response.
/// - Important: This node is statefull.
open class RequestSenderNode<Type>: AsyncNode, Aborter {

    /// Type for the node that will handle the server response.
    public typealias RawResponseProcessor = AsyncNode<NodeDataResponse, Type>

    /// Node for processing the response.
    public var rawResponseProcessor: any RawResponseProcessor

    /// Session manager
    private(set) var manager: URLSession
    private let dataTaskActor: URLSessionDataTaskActorProtocol

    /// Initializes the node.
    ///
    /// - Parameter rawResponseProcessor: The node for processing the response.
    /// - Parameter manager: URLSession manager, by default set to the session from ServerRequestsManager.
    public init(
        rawResponseProcessor: some RawResponseProcessor,
        dataTaskActor: URLSessionDataTaskActorProtocol? = nil,
        manager: URLSession? = nil
    ) {
        self.rawResponseProcessor = rawResponseProcessor
        self.dataTaskActor = dataTaskActor ?? URLSessionDataTaskActor()
        self.manager = manager ?? ServerRequestsManager.shared.manager
    }

    /// Executes the request, waits for the response, and passes it to the next node.
    ///
    /// - Parameter request: The data for executing the request.
    open func process(
        _ request: URLRequest,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<Type> {
        await .withCheckedCancellation {
            var log = Log(logViewObjectName, id: objectName, order: LogOrder.requestSenderNode)
            
            async let nodeResponse = nodeResponse(request, logContext: logContext)
            
            log += "Request sended!"
            
            let response = await nodeResponse
            
            log += "Get response!)"
            
            let result = await rawResponseProcessor.process(response, logContext: logContext)

            await logContext.add(log)
            return result
        }
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
