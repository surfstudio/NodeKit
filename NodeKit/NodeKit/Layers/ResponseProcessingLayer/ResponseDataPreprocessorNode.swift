//
//  ResponseDataProcessorNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 04/02/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// This node handles deserialization of response data into `JSON`.
/// In case of a 204 response, it passes an empty `Json`.
open class ResponseDataPreprocessorNode: AsyncNode {

    /// The next node for processing.
    public var next: any ResponseProcessingLayerNode

    /// Initializes the node.
    ///
    /// - Parameter next: The next node for processing.
    public init(next: some ResponseProcessingLayerNode) {
        self.next = next
    }


    /// Serializes "raw" data into `Json`.
    ///
    /// - Parameter data: The representation of the response.
    open func process(
        _ data: URLDataResponse,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<Json> {
        await .withCheckedCancellation {
            var log = Log(logViewObjectName, id: objectName, order: LogOrder.responseDataPreprocessorNode)

            guard data.response.statusCode != 204 else {
                log += "Status code is 204 -> response data is empty -> terminate process with empty json"
                await logContext.add(log)
                return .success(Json())
            }

            if let jsonObject = try? JSONSerialization.jsonObject(
                    with: data.data,
                    options: .allowFragments
                ),
                jsonObject is NSNull
            {
                log += "Json serialization sucess but json is NSNull -> terminate process with empty json"
                await logContext.add(log)
                return .success(Json())
            }

            return await next.process(data, logContext: logContext)
        }
    }
}
