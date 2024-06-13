//
//  MultipartFormDataFactoryMock.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 05.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import NodeKit
import NodeKitThirdParty

public class MultipartFormDataFactoryMock: MultipartFormDataFactory {
    
    public init() { }
    
    public var invokedProduce = false
    public var invokedProduceCount = 0
    public var stubbedProduceResult: MultipartFormDataProtocol!
    
    public func produce() -> MultipartFormDataProtocol {
        invokedProduce = true
        invokedProduceCount += 1
        return stubbedProduceResult
    }
}
