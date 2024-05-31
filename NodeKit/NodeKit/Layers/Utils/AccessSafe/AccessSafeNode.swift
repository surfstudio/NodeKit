//
//  AccessSafeNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 22/02/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// Error for the access-saving node.
///
/// - nodeWasReleased: Occurs when the node is released from memory.
public enum AccessSafeNodeError: Error {
    case nodeWasRelease
}

/// ## Description
/// Node implementing logic for maintaining access to a remote resource.
/// Let us consider a scheme for OAuth 2.0.
///
/// ## Example
/// After authorization, the user receives:
/// - AccessToken - to access the resource. The token has a lifetime.
/// - RefreshToken - a token to refresh the AccessToken without going through the authentication procedure.
///
/// Let's consider a situation with an "expired" token:
/// 1. Send a request with the "expired" token.
/// 2. The server returns an error with code 403 (or 401).
/// 3. The node initiates a chain to refresh the token, while saving the request itself.
/// 4. The chain returns a result:
///     1. Success - continue working.
///     2. Error - chain execution ends.
/// 5. Retry the request with the new token.
///
/// ## Need to Know
/// - Important: It is obvious that this node should be placed **before** the node that inserts the token into the request.
///
/// The node also handles multiple requests in a thread-safe manner.
/// That is, if we send multiple requests "simultaneously" and the first request fails due to access error, all other requests will be frozen.
/// When the token is refreshed, all frozen requests will be resent to the network.
///
/// Obviously, if a new request comes in during the token refresh wait, it will also be frozen and later resent.
///
/// - Warning: There is a possibility that a request will not be sent if it was sent at the exact moment when the token was refreshed and we started sending requests again, but the probability of this event is extremely low. You would need to send hundreds of requests per second to achieve this. Moreover, this situation is most likely impossible because after token refresh, the request won't be frozen.
open class AccessSafeNode<Output>: AsyncNode {

    /// The next node for processing.
    public var next: any AsyncNode<TransportURLRequest, Output>

    /// Token refresh chain.
    /// This chain should initially disable the node that implements request freezing and resumption.
    /// Out of the box, this is implemented by the ``TokenRefresherNode`` node.
    public var updateTokenChain: any AsyncNode<Void, Void>

    /// Initializer.
    ///
    /// - Parameters:
    ///   - next: The next node in the chain.
    ///   - updateTokenChain: The token update chain.
    public init(next: some AsyncNode<TransportURLRequest, Output>, updateTokenChain: some AsyncNode<Void, Void>) {
        self.next = next
        self.updateTokenChain = updateTokenChain
    }

    /// Passes control to the next node.
    /// If access is returned, it updates the token and retries the request.
    open func process(
        _ data: TransportURLRequest,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<Output> {
        await .withCheckedCancellation {
            await next.process(data, logContext: logContext)
        }
        .asyncFlatMapError { error in
            switch error {
            case ResponseHttpErrorProcessorNodeError.forbidden, ResponseHttpErrorProcessorNodeError.unauthorized:
                return await processWithTokenUpdate(data, logContext: logContext)
            default:
                return .failure(error)
            }
        }
    }

    // MARK: - Private Methods

    private func processWithTokenUpdate(
        _ data: TransportURLRequest,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<Output> {
        await .withCheckedCancellation {
            await updateTokenChain.process((), logContext: logContext)
                .asyncFlatMap { await next.process(data, logContext: logContext) }
        }
    }
}
