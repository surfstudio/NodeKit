//
//  TokenRefresherNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 06/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// Node for token refreshing and freezing requests.
open class TokenRefresherNode: AsyncNode {

    /// Actor for token refreshing.
    private let tokenRefresherActor: TokenRefresherActorProtocol

    /// Initializes.
    ///
    /// - Parameter tokenRefreshChain: Chain for token refreshing.
    public init(tokenRefreshChain: any AsyncNode<Void, Void>) {
        self.tokenRefresherActor = TokenRefresherActor(tokenRefreshChain: tokenRefreshChain)
    }
    
    /// Initializes.
    ///
    /// - Parameter tokenRefresherActor: Actor for token refreshing.
    public init(tokenRefresherActor: TokenRefresherActorProtocol) {
        self.tokenRefresherActor = tokenRefresherActor
    }

    /// Calls the refresh method on the token refreshing actor.
    open func process(
        _ data: Void,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<Void> {
        await .withCheckedCancellation {
            await tokenRefresherActor.refresh(logContext: logContext)
        }
    }
}
