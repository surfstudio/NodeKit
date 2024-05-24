//
//  ServiceChainProviderMock.swift
//  NodeKitMock
//
//  Created by Andrei Frolov on 02.05.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit

import Foundation

open class ServiceChainProviderMock: ServiceChainProvider {
    
    public init() { }
    
    public var invokedProvideRequestJsonChain = false
    public var invokedProvideRequestJsonChainCount = 0
    public var invokedProvideRequestJsonChainParameter: [MetadataProvider]?
    public var invokedProvideRequestJsonChainParameterList: [[MetadataProvider]] = []
    public var stubbedProvideRequestJsonChainResult: (any AsyncNode<TransportURLRequest, Json>)!
    
    open func provideRequestJsonChain(
        with providers: [MetadataProvider]
    ) -> any AsyncNode<TransportURLRequest, Json> {
        invokedProvideRequestJsonChain = true
        invokedProvideRequestJsonChainCount += 1
        invokedProvideRequestJsonChainParameter = providers
        invokedProvideRequestJsonChainParameterList.append(providers)
        return stubbedProvideRequestJsonChainResult
    }
    
    public var invokedProvideRequestDataChain = false
    public var invokedProvideRequestDataChainCount = 0
    public var invokedProvideRequestDataChainParameter: [MetadataProvider]?
    public var invokedProvideRequestDataChainParameterList: [[MetadataProvider]] = []
    public var stubbedProvideRequestDataChainResult: (any AsyncNode<TransportURLRequest, Data>)!
    
    open func provideRequestDataChain(
        with providers: [MetadataProvider]
    ) -> any AsyncNode<TransportURLRequest, Data> {
        invokedProvideRequestDataChain = true
        invokedProvideRequestDataChainCount += 1
        invokedProvideRequestDataChainParameter = providers
        invokedProvideRequestDataChainParameterList.append(providers)
        return stubbedProvideRequestDataChainResult
    }
    
    public var invokedProvideRequestMultipartChain = false
    public var invokedProvideRequestMultipartChainCount = 0
    public var stubbedProvideRequestMultipartChainResult: (any AsyncNode<MultipartURLRequest, Json>)!
    
    open func provideRequestMultipartChain() -> any AsyncNode<MultipartURLRequest, Json> {
        invokedProvideRequestMultipartChain = true
        invokedProvideRequestMultipartChainCount += 1
        return stubbedProvideRequestMultipartChainResult
    }
}
