//
//  URLSessionDataTaskActorMock.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 08.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import Foundation
import NodeKit

public actor URLSessionDataTaskActorMock: URLSessionDataTaskActorProtocol {
    
    public init() { }
    
    public var invokedStore = false
    public var invokedStoreCount = 0
    public var invokedStoreParemeter: CancellableTask?
    public var invokedStoreParameterList: [CancellableTask] = []
    
    public func store(task: CancellableTask) {
        invokedStore = true
        invokedStoreCount += 1
        invokedStoreParemeter = task
        invokedStoreParameterList.append(task)
    }
    
    public var invokedCancelTask = false
    public var invokedCancelTaskCount = 0
    
    public func cancelTask() {
        invokedCancelTask = true
        invokedCancelTaskCount += 1
    }
}
