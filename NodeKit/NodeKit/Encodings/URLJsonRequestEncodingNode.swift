//
//  URLJsonRequestEncodingNode.swift
//  NodeKit
//
//  Created by Vladislav Krupenko on 06.05.2020.
//  Copyright © 2020 Кравченков Александр. All rights reserved.
//

import Foundation

open class URLJsonRequestEncodingNode<Type>: AsyncNode {

    /// The next node for processing.
    public var next: any AsyncNode<TransportURLRequest, Type>

    /// Initializer.
    ///
    /// - Parameters:
    ///   - next: The next node for processing.
    public init(next: some AsyncNode<TransportURLRequest, Type>) {
        self.next = next
    }

    open func process(
        _ data: RequestEncodingModel,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<Type> {
        await .withCheckedCancellation {
            var log = getLogMessage(data)
            let paramEncoding = parameterEncoding(from: data)

            guard let encoding = paramEncoding else {
                log += "Missed encoding type -> terminate with error"
                await logContext.add(log)
                return .failure(RequestEncodingNodeError.missedJsonEncodingType)
            }
            do {
                let request = try encoding.encode(urlParameters: data.urlParameters, parameters: data.raw)
                log += "type: Json"
                return await next.process(request, logContext: logContext)
            } catch {
                log += "But can't encode data -> terminate with error"
                await logContext.add(log)
                return .failure(RequestEncodingNodeError.unsupportedDataType)
            }
        }
    }

    // MARK: - Private Methods

    private func parameterEncoding(from data: RequestEncodingModel) -> ParameterEncoding? {
        if data.urlParameters.method == .get {
            return URLEncoding.default
        }
        return data.encoding?.raw
        
    }

    private func getLogMessage(_ data: RequestEncodingModel) -> LogChain {
        let message = "input: \(type(of: data))" +
            "encoding: \(String(describing: data.encoding))" +
            "raw: \(String(describing: data.raw))"
        return LogChain(message, id: self.objectName, logType: .info, order: LogOrder.requestEncodingNode)
    }
}
