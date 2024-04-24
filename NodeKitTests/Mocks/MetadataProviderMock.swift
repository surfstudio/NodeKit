//
//  MetadataProviderMock.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 04.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit

final class MetadataProviderMock: MetadataProvider {
    
    var invokedMetadata = false
    var invokedMetadataCount = 0
    var stubbedMetadataResult: [String: String] = [:]
    
    func metadata() -> [String : String] {
        invokedMetadata = true
        invokedMetadataCount += 1
        return stubbedMetadataResult
    }
}
