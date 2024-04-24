//
//  URLSessionDataTaskMock.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 08.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import Foundation

final class URLSessionDataTaskMock: URLSessionDataTask {
    
    static var invokedResume = false
    static var invokedResumeCount = 0
    
    override func resume() {
        URLSessionDataTaskMock.invokedResume = true
        URLSessionDataTaskMock.invokedResumeCount += 1
        super.resume()
    }
    
    static var invokedCancel = false
    static var invokedCancelCount = 0
    
    override func cancel() {
        URLSessionDataTaskMock.invokedCancel = true
        URLSessionDataTaskMock.invokedResumeCount += 1
        super.cancel()
    }
    
}
