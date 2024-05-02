//
//  VoidChainBuilder.swift
//  NodeKit
//
//  Created by Andrei Frolov on 02.05.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import Foundation

public protocol VoidChainBuilder {
    func build<O: DTODecodable>() -> any AsyncNode<Void, O>
        where O.DTO.Raw == Json
    
    func build<I: DTOEncodable>() -> any AsyncNode<I, Void>
        where I.DTO.Raw == Json
    
    func build() -> any AsyncNode<Void, Void>
}

open class URLVoidChainBuilder: VoidChainBuilder {
    
    // MARK: - Public Properties
    
    public let metadataConnectorNode: any AsyncNode<Json, Json>
    public let logFilter: [String]
    
    // MARK: - Initialization
    
    public init(
        metadataConnectorNode: any AsyncNode<Json, Json>,
        logFilter: [String]
    ) {
        self.metadataConnectorNode = metadataConnectorNode
        self.logFilter = logFilter
    }
    
    // MARK: - VoidChainBuilder
    
    open func build<O: DTODecodable>() -> any AsyncNode<Void, O> where O.DTO.Raw == Json {
        let dtoConverter = DTOMapperNode<Json, O.DTO>(next: metadataConnectorNode)
        let modelInput = ModelInputNode<Json, O>(next: dtoConverter)
        let voidNode = VoidInputNode(next: modelInput)
        return LoggerNode(next: voidNode, filters: logFilter)
    }
    
    open func build<I: DTOEncodable>() -> any AsyncNode<I, Void> where I.DTO.Raw == Json {
        let voidOutput = VoidOutputNode<I>(next: metadataConnectorNode)
        return LoggerNode(next: voidOutput, filters: logFilter)
    }
    
    open func build() -> any AsyncNode<Void, Void> {
        let voidOutput = VoidIONode(next: metadataConnectorNode)
        return LoggerNode(next: voidOutput, filters: logFilter)
    }
}
