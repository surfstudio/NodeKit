//
//  DataLoadingResponseProcessor.swift
//  NodeKit
//
//  Created by Александр Кравченков on 18/05/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// This node simply returns a byte array from the request.
/// Should be used for cases where conversion to JSON is not needed or not possible (e.g., loading images).
/// Contains a reference to the next node needed for post-processing.
/// For example, it can be used for saving.
open class DataLoadingResponseProcessor: AsyncNode {

    /// Node for post-processing loaded data.
    open var next: (any AsyncNode<URLDataResponse, Void>)?

    /// Initializes the node.
    ///
    /// - Parameter next: The node for post-processing loaded data. Default is nil.
    public init(next: (any AsyncNode<URLDataResponse, Void>)? = nil) {
        self.next = next
    }

    /// If the post-processing node exists, it calls it; if not, it returns the data.
    open func process(
        _ data: URLDataResponse,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<Data> {
        await .withCheckedCancellation {
            await next?.process(data, logContext: logContext)
                .map { data.data } ?? .success(data.data)
        }
    }
}
