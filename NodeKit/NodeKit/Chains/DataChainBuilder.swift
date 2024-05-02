//
//  DataChainBuilder.swift
//  NodeKit
//
//  Created by Andrei Frolov on 02.05.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import Foundation

public protocol DataChainBuilder {
    func build() -> any AsyncNode<Void, Data>
    func build<I: DTOEncodable>() -> any AsyncNode<I, Data> where I.DTO.Raw == Json
}

open class URLDataChainBuilder: DataChainBuilder {
    
    // MARK: - Public Properties
    
    public let metadataConnectorNode: any AsyncNode<Json, Data>
    public let logFilter: [String]
    
    // MARK: - Initialization
    
    public init(
        metadataConnectorNode: any AsyncNode<Json, Data>,
        logFilter: [String]
    ) {
        self.metadataConnectorNode = metadataConnectorNode
        self.logFilter = logFilter
    }
    
    // MARK: - DataChainBuilder
    
    open func build() -> any AsyncNode<Void, Data> {
        let voidInput = VoidInputNode(next: metadataConnectorNode)
        return LoggerNode(next: voidInput, filters: logFilter)
    }
    
    open func build<I>() -> any AsyncNode<I, Data> where I : DTOEncodable, I.DTO.Raw == Json {
        let rawEncoder = RawEncoderNode<I.DTO, Data>(next: metadataConnectorNode)
        let dtoEncoder = DTOEncoderNode<I, Data>(rawEncodable: rawEncoder)
        return LoggerNode(next: dtoEncoder, filters: logFilter)
    }
}
