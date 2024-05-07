//
//  TokenRefresherActorMock.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 22.03.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import NodeKit

public actor TokenRefresherActorMock: TokenRefresherActorProtocol {
    
    public init() { }
    
    public var invokedRefresh = false
    public var invokedRefreshCount = 0
    public var invokedRefreshPrameter: LoggingContextProtocol?
    public var invokedRefreshParameterList: [LoggingContextProtocol] = []
    public var stubbedRefreshRunFunction: (() async -> Void)?
    public var stubbedRefreshResult: NodeResult<Void>!
    
    public func stub(result: NodeResult<Void>!) {
        stubbedRefreshResult = result
    }
    
    public func stub(runFunction: @escaping (() async -> Void)) {
        stubbedRefreshRunFunction = runFunction
    }
    
    public func refresh(logContext: LoggingContextProtocol) async -> NodeResult<Void> {
        invokedRefresh = true
        invokedRefreshCount += 1
        invokedRefreshPrameter = logContext
        invokedRefreshParameterList.append(logContext)
        if let function = stubbedRefreshRunFunction {
            await function()
        }
        return stubbedRefreshResult
    }
    
    public var invokedUpdate = false
    public var invokedUpdateCount = 0
    public var invokedUpdatePrameter: (any AsyncNode)?
    public var invokedUpdateParameterList: [any AsyncNode] = []
    
    public func update(tokenRefreshChain: some AsyncNode<Void, Void>) {
        invokedUpdate = true
        invokedUpdateCount += 1
        invokedUpdatePrameter = tokenRefreshChain
        invokedUpdateParameterList.append(tokenRefreshChain)
    }
}
