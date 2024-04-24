//
//  NetworkMock.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 08.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import Foundation

protocol URLSessionDataTaskProtocol {
  func resume()
  func cancel()
}

protocol URLSessionProtocol {
    func dataTask(
        with request: URLRequest,
        completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void
    ) -> URLSessionDataTask
}

final class NetworkMock {
    
    var urlSession: URLSession {
        let configuration: URLSessionConfiguration = .ephemeral
        configuration.protocolClasses = [URLProtocolMock.self, URLSessionDataTaskMock.self]
        configuration.timeoutIntervalForRequest = 100000
        return URLSession(configuration: configuration)
    }
    
}
