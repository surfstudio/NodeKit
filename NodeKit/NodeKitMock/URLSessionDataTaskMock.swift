//
//  URLSessionDataTaskMock.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 08.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import Foundation

public class URLSessionDataTaskMock: URLSessionDataTask {
    
    public static var invokedResume = false
    public static var invokedResumeCount = 0
    
    public override func resume() {
        URLSessionDataTaskMock.invokedResume = true
        URLSessionDataTaskMock.invokedResumeCount += 1
        super.resume()
    }
    
    public static var invokedCancel = false
    public static var invokedCancelCount = 0
    
    override public func cancel() {
        URLSessionDataTaskMock.invokedCancel = true
        URLSessionDataTaskMock.invokedResumeCount += 1
        super.cancel()
    }
    
}
