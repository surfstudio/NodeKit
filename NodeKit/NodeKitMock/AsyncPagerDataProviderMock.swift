//
//  AsyncPagerDataProviderMock.swift
//  NodeKitMock
//
//  Created by Andrei Frolov on 15.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit

public class AsyncPagerDataProviderMock<Value>: AsyncPagerDataProvider {
    
    public var invokedProvide = false
    public var invokedProvideCount = 0
    public var invokedProvideParameters: (index: Int, pageSize: Int)?
    public var invokedProvideParametersList: [(index: Int, pageSize: Int)] = []
    public var stubbedProvideResult: NodeResult<AsyncPagerData<Value>>!
    
    public func provide(for index: Int, with pageSize: Int) async -> NodeResult<AsyncPagerData<Value>> {
        invokedProvide = true
        invokedProvideCount += 1
        invokedProvideParameters = (index, pageSize)
        invokedProvideParametersList.append((index, pageSize))
        return stubbedProvideResult
    }
}
