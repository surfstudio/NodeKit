//
//  LoggingContextMock.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 22.03.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import NodeKit

public actor LoggingContextMock: LoggingContextProtocol {
    
    public init() { }
    
    public private(set) var log: (Logable)?
    
    public var invokedAdd = false
    public var invokedAddCount = 0
    public var invokedAddParameter: Logable?
    public var invokedAddParameterList: [Logable?] = []
    
    public func add(_ log: Logable?) {
        invokedAdd = true
        invokedAddCount += 1
        invokedAddParameter = log
        invokedAddParameterList.append(log)
    }
}
