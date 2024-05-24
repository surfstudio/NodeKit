//
//  URLRouteProviderMock.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 05.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import Foundation
import NodeKit

public class URLRouteProviderMock: URLRouteProvider {
    
    public init() { }
    
    public var invokedURL = false
    public var invokedURLCount = 0
    public var stubbedURLResult: Result<URL, Error>!
    
    public func url() throws -> URL {
        invokedURL = true
        invokedURLCount += 1
        switch stubbedURLResult! {
        case .success(let url):
            return url
        case .failure(let error):
            throw error
        }
    }
}
