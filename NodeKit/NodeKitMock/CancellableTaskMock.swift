//
//  CancellableTaskMock.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 08.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import NodeKit

public class CancellableTaskMock: CancellableTask {
    
    public init() { }
    
    public var invokedCancel = false
    public var invokedCancelCount = 0
    
    public func cancel() {
        invokedCancel = true
        invokedCancelCount += 1
    }
}
