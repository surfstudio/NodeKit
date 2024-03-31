//
//  NodeAdapterOutputMock.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 29.03.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit

final class NodeAdapterOutputMock<Output>: NodeAdapterOutput {
    
    var invokedSend = false
    var invokedSendCount = 0
    var invokedSendParameter: NodeResult<Output>?
    var invokedSendParameterList: [NodeResult<Output>] = []
    
    func send(_ value: NodeResult<Output>) {
        invokedSend = true
        invokedSendCount += 1
        invokedSendParameter = value
        invokedSendParameterList.append(value)
    }
}
