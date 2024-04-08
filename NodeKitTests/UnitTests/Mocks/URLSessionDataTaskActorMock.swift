//
//  URLSessionDataTaskActorMock.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 08.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit
import Foundation

actor URLSessionDataTaskActorMock: URLSessionDataTaskActorProtocol {
    
    var invokedStore = false
    var invokedStoreCount = 0
    var invokedStoreParemeter: CancellableTask?
    var invokedStoreParameterList: [CancellableTask] = []
    
    func store(task: CancellableTask) {
        invokedStore = true
        invokedStoreCount += 1
        invokedStoreParemeter = task
        invokedStoreParameterList.append(task)
    }
    
    var invokedCancelTask = false
    var invokedCancelTaskCount = 0
    
    func cancelTask() {
        invokedCancelTask = true
        invokedCancelTaskCount += 1
    }
}
