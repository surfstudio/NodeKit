//
//  URLProtocolMock.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 08.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import Foundation

public class URLProtocolMock: URLProtocol {
    
    override public class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override public class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    public static var invokedStartLoading = false
    public static var invokedStartLoadingCount = 0
    public static var stubbedError: Error?
    public static var stubbedRequestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
    
    public override func startLoading() {
        URLProtocolMock.invokedStartLoading = true
        URLProtocolMock.invokedStartLoadingCount += 1
        
        if let error = URLProtocolMock.stubbedError {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }
        
        guard let handler = URLProtocolMock.stubbedRequestHandler else {
            assertionFailure("Received unexpected request with no handler set")
            return
        }
        
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    public static var invokedStopLoading = false
    public static var invokedStopLoadingCount = 0
    
    override public func stopLoading() {
        URLProtocolMock.invokedStopLoading = true
        URLProtocolMock.invokedStopLoadingCount += 1
    }
    
    public static func flush() {
        URLProtocolMock.invokedStartLoading = false
        URLProtocolMock.invokedStartLoadingCount = 0
        URLProtocolMock.stubbedError = nil
        URLProtocolMock.stubbedRequestHandler = nil
        URLProtocolMock.invokedStopLoading = false
        URLProtocolMock.invokedStopLoadingCount = 0
    }
}
