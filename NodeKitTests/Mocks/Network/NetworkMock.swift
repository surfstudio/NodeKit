//
//  NetworkMock.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 08.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import Foundation

final class NetworkMock {
    
    var urlSession: URLSession {
        let configuration: URLSessionConfiguration = .ephemeral
        configuration.protocolClasses = [URLProtocolMock.self, URLSessionDataTaskMock.self]
        configuration.timeoutIntervalForRequest = 100000
        return URLSession(configuration: configuration)
    }
    
}
