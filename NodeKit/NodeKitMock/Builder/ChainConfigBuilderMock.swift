//
//  ChainConfigBuilderMock.swift
//  NodeKitMock
//
//  Created by Andrei Frolov on 02.05.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit

open class ChainConfigBuilderMock: ChainConfigBuilder {
    
    public init() { }
    
    public var invokedSetQuery = false
    public var invokedSetQueryCount = 0
    public var invokedSetQueryParameter: [String: Any]?
    public var invokedSetQueryParameterList: [[String: Any]] = []
    
    open func set(query: [String: Any]) -> Self {
        invokedSetQuery = true
        invokedSetQueryCount += 1
        invokedSetQueryParameter = query
        invokedSetQueryParameterList.append(query)
        return self
    }
    
    public var invokedSetBoolEncodingStartegy = false
    public var invokedSetBoolEncodingStartegyCount = 0
    public var invokedSetBoolEncodingStartegyParameter: URLQueryBoolEncodingStartegy?
    public var invokedSetBoolEncodingStartegyParameterList: [URLQueryBoolEncodingStartegy] = []
    
    open func set(boolEncodingStartegy: URLQueryBoolEncodingStartegy) -> Self {
        invokedSetBoolEncodingStartegy = true
        invokedSetBoolEncodingStartegyCount += 1
        invokedSetBoolEncodingStartegyParameter = boolEncodingStartegy
        invokedSetBoolEncodingStartegyParameterList.append(boolEncodingStartegy)
        return self
    }
    
    public var invokedSetArrayEncodingStrategy = false
    public var invokedSetArrayEncodingStrategyCount = 0
    public var invokedSetArrayEncodingStrategyParameter: URLQueryArrayKeyEncodingStartegy?
    public var invokedSetArrayEncodingStrategyParameterList: [URLQueryArrayKeyEncodingStartegy] = []
    
    open func set(arrayEncodingStrategy: URLQueryArrayKeyEncodingStartegy) -> Self {
        invokedSetArrayEncodingStrategy = true
        invokedSetArrayEncodingStrategyCount += 1
        invokedSetArrayEncodingStrategyParameter = arrayEncodingStrategy
        invokedSetArrayEncodingStrategyParameterList.append(arrayEncodingStrategy)
        return self
    }
    
    public var invokedSetDictEncodindStrategy = false
    public var invokedSetDictEncodindStrategyCount = 0
    public var invokedSetDictEncodindStrategyParameter: URLQueryDictionaryKeyEncodingStrategy?
    public var invokedSetDictEncodindStrategyParameterList: [URLQueryDictionaryKeyEncodingStrategy] = []
    
    open func set(dictEncodindStrategy: URLQueryDictionaryKeyEncodingStrategy) -> Self {
        invokedSetDictEncodindStrategy = true
        invokedSetDictEncodindStrategyCount += 1
        invokedSetDictEncodindStrategyParameter = dictEncodindStrategy
        invokedSetDictEncodindStrategyParameterList.append(dictEncodindStrategy)
        return self
    }
    
    public var invokedSetBoolEncodingDefaultStartegy = false
    public var invokedSetBoolEncodingDefaultStartegyCount = 0
    public var invokedSetBoolEncodingDefaultStartegyParameter: URLQueryBoolEncodingDefaultStartegy?
    public var invokedSetBoolEncodingDefaultStartegyParameterList: [URLQueryBoolEncodingDefaultStartegy] = []
    
    open func set(boolEncodingStartegy: URLQueryBoolEncodingDefaultStartegy) -> Self {
        invokedSetBoolEncodingDefaultStartegy = true
        invokedSetBoolEncodingDefaultStartegyCount += 1
        invokedSetBoolEncodingDefaultStartegyParameter = boolEncodingStartegy
        invokedSetBoolEncodingDefaultStartegyParameterList.append(boolEncodingStartegy)
        return self
    }
    
    public var invokedSetArrayEncodingBracketsStrategy = false
    public var invokedSetArrayEncodingBracketsStrategyCount = 0
    public var invokedSetArrayEncodingBracketsStrategyParameter: URLQueryArrayKeyEncodingBracketsStartegy?
    public var invokedSetArrayEncodingBracketsStrategyParameterList: [URLQueryArrayKeyEncodingBracketsStartegy] = []
    
    open func set(arrayEncodingStrategy: URLQueryArrayKeyEncodingBracketsStartegy) -> Self {
        invokedSetArrayEncodingBracketsStrategy = true
        invokedSetArrayEncodingBracketsStrategyCount += 1
        invokedSetArrayEncodingBracketsStrategyParameter = arrayEncodingStrategy
        invokedSetArrayEncodingBracketsStrategyParameterList.append(arrayEncodingStrategy)
        return self
    }
}
