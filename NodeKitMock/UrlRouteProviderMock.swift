//
//  UrlRouteProviderMock.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 05.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import NodeKit

public class UrlRouteProviderMock: UrlRouteProvider {
    
    public init() { }
    
    public var invokedUrl = false
    public var invokedUrlCount = 0
    public var stubbedUrlResult: Result<URL, Error>!
    
    public func url() throws -> URL {
        invokedUrl = true
        invokedUrlCount += 1
        switch stubbedUrlResult! {
        case .success(let url):
            return url
        case .failure(let error):
            throw error
        }
    }
}
