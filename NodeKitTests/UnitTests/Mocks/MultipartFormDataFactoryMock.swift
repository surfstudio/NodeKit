//
//  MultipartFormDataFactoryMock.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 05.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit

final class MultipartFormDataFactoryMock: MultipartFormDataFactory {
    
    var invokedProduce = false
    var invokedProduceCount = 0
    var stubbedProduceResult: MultipartFormDataProtocol!
    
    func produce() -> MultipartFormDataProtocol {
        invokedProduce = true
        invokedProduceCount += 1
        return stubbedProduceResult
    }
}
