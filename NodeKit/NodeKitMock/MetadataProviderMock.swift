//
//  MetadataProviderMock.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 04.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import NodeKit

public class MetadataProviderMock: MetadataProvider {
    
    public init() { }
    
    public var invokedMetadata = false
    public var invokedMetadataCount = 0
    public var stubbedMetadataResult: [String: String] = [:]
    
    public func metadata() -> [String : String] {
        invokedMetadata = true
        invokedMetadataCount += 1
        return stubbedMetadataResult
    }
}
