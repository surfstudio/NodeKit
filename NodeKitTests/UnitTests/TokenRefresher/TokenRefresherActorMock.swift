//
//  TokenRefresherActorMock.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 22.03.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit

actor TokenRefresherActorMock: TokenRefresherActorProtocol {
    
    var invokedRefresh = false
    var invokedRefreshCount = 0
    var invokedRefreshPrameter: LoggingContextProtocol?
    var invokedRefreshParameterList: [LoggingContextProtocol] = []
    var stubbedRefreshResult: NodeResult<Void>!
    
    func stub(result: NodeResult<Void>!) {
        stubbedRefreshResult = result
    }
    
    func refresh(logContext: LoggingContextProtocol) async -> NodeResult<Void> {
        invokedRefresh = true
        invokedRefreshCount += 1
        invokedRefreshPrameter = logContext
        invokedRefreshParameterList.append(logContext)
        return stubbedRefreshResult
    }
    
    var invokedUpdate = false
    var invokedUpdateCount = 0
    var invokedUpdatePrameter: (any AsyncNode)?
    var invokedUpdateParameterList: [any AsyncNode] = []
    
    func update(tokenRefreshChain: some AsyncNode<Void, Void>) {
        invokedUpdate = true
        invokedUpdateCount += 1
        invokedUpdatePrameter = tokenRefreshChain
        invokedUpdateParameterList.append(tokenRefreshChain)
    }
}
