//
//  CancellableTaskMock.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 08.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit

final class CancellableTaskMock: CancellableTask {
    
    var invokedCancel = false
    var invokedCancelCount = 0
    
    func cancel() {
        invokedCancel = true
        invokedCancelCount += 1
    }
}
