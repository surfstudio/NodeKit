//
//  TechnicaErrorMapperNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 12/02/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// Errors for the ``TechnicaErrorMapperNode``.
///
/// - noInternetConnection: Occurs if a system error about the absence of a connection is returned.
/// - dataNotAllowed: Occurs if a system error 'kCFURLErrorDataNotAllowed' is returned 
/// (possible reason - no wifi, mobile internet could potentially be used but is turned off. Apple docs are extremely scarce in such explanations).
/// - timeout: Occurs if the server response waiting limit is exceeded.
/// - cantConnectToHost: Occurs if a connection to a specific address could not be established.
public enum BaseTechnicalError: Error {
    case noInternetConnection
    case dataNotAllowed
    case timeout
    case cantConnectToHost
}

/// This node handles the mapping of technical errors.
open class TechnicaErrorMapperNode: AsyncNode {

    /// The next node for processing.
    open var next: any AsyncNode<URLRequest, Json>


    /// Initializer.
    ///
    /// - Parameter next: The next node for processing.
    public init(next: any AsyncNode<URLRequest, Json>) {
        self.next = next
    }

    /// Passes control to the next node, and in case of an error, maps it.
    ///
    /// - Parameter data: The data for processing.
    open func process(
        _ data: URLRequest,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<Json> {
        await .withCheckedCancellation {
            await next.process(data, logContext: logContext)
                .mapError { error in
                    switch (error as NSError).code {
                    case -1020:
                        return BaseTechnicalError.dataNotAllowed
                    case -1009:
                        return BaseTechnicalError.noInternetConnection
                    case -1001:
                        return BaseTechnicalError.timeout
                    case -1004:
                        return BaseTechnicalError.cantConnectToHost
                    default:
                        return error
                    }
                }
        }
    }
}
