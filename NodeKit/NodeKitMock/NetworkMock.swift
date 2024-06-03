//
//  NetworkMock.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 08.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import Foundation

public class NetworkMock {
    
    public init() { }
    
    public var urlSession: URLSession {
        let configuration: URLSessionConfiguration = .ephemeral
        configuration.protocolClasses = [URLProtocolMock.self]
        configuration.timeoutIntervalForRequest = 100000
        return URLSession(configuration: configuration)
    }
    
}
