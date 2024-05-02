//
//  MultipartChainBuilder.swift
//  NodeKit
//
//  Created by Andrei Frolov on 02.05.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import Foundation

public protocol MultipartChainBuilder {
    func build<I: DTOEncodable, O: DTODecodable>() -> any AsyncNode<I, O>
        where O.DTO.Raw == Json, I.DTO.Raw == MultipartModel<[String : Data]>
}

open class URLMultipartChainBuilder: MultipartChainBuilder {
    
    // MARK: - Public Properties
    
    public let metadataConnectorNode: any AsyncNode<MultipartModel<[String : Data]>, Json>
    public let logFilter: [String]
    
    // MARK: - Initialization
    
    public init(
        metadataConnectorNode: any AsyncNode<MultipartModel<[String : Data]>, Json>,
        logFilter: [String]
    ) {
        self.metadataConnectorNode = metadataConnectorNode
        self.logFilter = logFilter
    }
    
    // MARK: - MultipartChainBuilder
    
    open func build<I: DTOEncodable, O: DTODecodable>() -> any AsyncNode<I, O>
    where I.DTO.Raw == MultipartModel<[String : Data]>, O.DTO.Raw == Json {
        let rawEncoder = DTOMapperNode<I.DTO,O.DTO>(next: metadataConnectorNode)
        let dtoEncoder = ModelInputNode<I, O>(next: rawEncoder)
        return LoggerNode(next: dtoEncoder, filters: logFilter)
    }
}
