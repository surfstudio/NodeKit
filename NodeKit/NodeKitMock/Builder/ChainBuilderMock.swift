//
//  ChainBuilderMock.swift
//  NodeKitMock
//
//  Created by Andrei Frolov on 02.05.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit

import Foundation

open class ChainBuilderMock<Route: URLRouteProvider>: ChainConfigBuilderMock, ChainBuilder {
    
    public var invokedRoute = false
    public var invokedRouteCount = 0
    public var invokedRouteParameter: (method: NodeKit.Method, route: Route)?
    public var invokedRouteParameterList: [(method: NodeKit.Method, route: Route)] = []
    
    open func route(_ method: NodeKit.Method, _ route: Route) -> Self {
        invokedRoute = true
        invokedRouteCount += 1
        invokedRouteParameter = (method, route)
        invokedRouteParameterList.append((method, route))
        return self
    }
    
    public var invokedEncode = false
    public var invokedEncodeCount = 0
    public var invokedEncodeParameter: ParametersEncoding?
    public var invokedEncodeParameterList: [ParametersEncoding] = []
    
    open func encode(as encoding: ParametersEncoding) -> Self {
        invokedEncode = true
        invokedEncodeCount += 1
        invokedEncodeParameter = encoding
        invokedEncodeParameterList.append(encoding)
        return self
    }
    
    public var invokedAddProvider = false
    public var invokedAddProviderCount = 0
    public var invokedAddProviderParameter: MetadataProvider?
    public var invokedAddProviderParameterList: [MetadataProvider] = []
    
    open func add(provider: MetadataProvider) -> Self {
        invokedAddProvider = true
        invokedAddProviderCount += 1
        invokedAddProviderParameter = provider
        invokedAddProviderParameterList.append(provider)
        return self
    }
    
    public var invokedSetMetadata = false
    public var invokedSetMetadataCount = 0
    public var invokedSetMetadataParameter: [String: String]?
    public var invokedSetMetadataParameterList: [[String: String]] = []
    
    open func set(metadata: [String: String]) -> Self {
        invokedSetMetadata = true
        invokedSetMetadataCount += 1
        invokedSetMetadataParameter = metadata
        invokedSetMetadataParameterList.append(metadata)
        return self
    }
    
    public var invokedBuildWithInputOutput = false
    public var invokedBuildWithInputOutputCount = 0
    public var stubbedBuildWithInputOutputResult: Any!
    
    open func build<I: DTOEncodable, O: DTODecodable>() -> AnyAsyncNode<I, O>
    where I.DTO.Raw == Json, O.DTO.Raw == Json {
        invokedBuildWithInputOutput = true
        invokedBuildWithInputOutputCount += 1
        return (stubbedBuildWithInputOutputResult as! AsyncNodeMock<I, O>).eraseToAnyNode()
    }
    
    public var invokedBuildWithVoidInput = false
    public var invokedBuildWithVoidInputCount = 0
    public var stubbedBuildWithVoidInputResult: Any!
    
    open func build<O: DTODecodable>() -> AnyAsyncNode<Void, O>
    where O.DTO.Raw == Json {
        invokedBuildWithVoidInput = true
        invokedBuildWithVoidInputCount += 1
        return (stubbedBuildWithVoidInputResult as! AsyncNodeMock<Void, O>).eraseToAnyNode()
    }
    
    public var invokedBuildWithVoidOutput = false
    public var invokedBuildWithVoidOutputCount = 0
    public var stubbedBuildWithVoidOutputResult: Any!
    
    open func build<I: DTOEncodable>() -> AnyAsyncNode<I, Void> where I.DTO.Raw == Json {
        invokedBuildWithVoidOutput = true
        invokedBuildWithVoidOutputCount += 1
        return (stubbedBuildWithVoidOutputResult as! AsyncNodeMock<I, Void>).eraseToAnyNode()
    }
    
    public var invokedBuildWithVoidInputOutput = false
    public var invokedBuildWithVoidInputOutputCount = 0
    public var stubbedBuildWithVoidInputOutputResult: AsyncNodeMock<Void, Void>!
    
    open func build() -> AnyAsyncNode<Void, Void> {
        invokedBuildWithVoidInputOutput = true
        invokedBuildWithVoidInputOutputCount += 1
        return stubbedBuildWithVoidInputOutputResult.eraseToAnyNode()
    }
    
    public var invokedBuildMultipart = false
    public var invokedBuildMultipartCount = 0
    public var stubbedBuildMultipartResult: Any!
    
    open func build<I: DTOEncodable, O: DTODecodable>() -> AnyAsyncNode<I, O>
    where O.DTO.Raw == Json, I.DTO.Raw == MultipartModel<[String : Data]> {
        invokedBuildMultipart = true
        invokedBuildMultipartCount += 1
        return (stubbedBuildMultipartResult as! AsyncNodeMock<I, O>).eraseToAnyNode()
    }
    
    public var invokedBuildDataLoadingWithVoidInput = false
    public var invokedBuildDataLoadingWithVoidInputCount = 0
    public var stubbedBuildDataLoadingWithVoidInputResult: AsyncNodeMock<Void, Data>!
    
    open func buildDataLoading() -> AnyAsyncNode<Void, Data> {
        invokedBuildDataLoadingWithVoidInput = true
        invokedBuildDataLoadingWithVoidInputCount += 1
        return stubbedBuildDataLoadingWithVoidInputResult.eraseToAnyNode()
    }
    
    public var invokedBuildDataLoading = false
    public var invokedBuildDataLoadingCount = 0
    public var stubbedBuildDataLoadingResult: Any!
    
    open func buildDataLoading<I: DTOEncodable>() -> AnyAsyncNode<I, Data> where I.DTO.Raw == Json {
        invokedBuildDataLoading = true
        invokedBuildDataLoadingCount += 1
        return (stubbedBuildDataLoadingResult as! AsyncNodeMock<I, Data>).eraseToAnyNode()
    }
}
