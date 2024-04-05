//
//  UrlRouteProviderMock.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 05.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit

final class UrlRouteProviderMock: UrlRouteProvider {
    
    var invokedUrl = false
    var invokedUrlCount = 0
    var stubbedUrlResult: Result<URL, Error>!
    
    func url() throws -> URL {
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
