//
//  LoggingContextMock.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 22.03.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit

final actor LoggingContextMock: LoggingContextProtocol {
    
    private(set) var log: (Logable)?
    
    var invokedAdd = false
    var invokedAddCount = 0
    var invokedAddParameter: Logable?
    var invokedAddParameterList: [Logable?] = []
    
    func add(_ log: Logable?) {
        invokedAdd = true
        invokedAddCount += 1
        invokedAddParameter = log
        invokedAddParameterList.append(log)
    }
}
