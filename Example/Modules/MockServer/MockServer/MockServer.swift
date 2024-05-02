//
//  MockServer.swift
//  Example
//
//  Created by Andrei Frolov on 11.04.24.
//  Copyright © 2024 Кравченков Александр. All rights reserved.
//

import Foundation
import Models
import NodeKitMock

public enum MockServer {
    
    public static func start() {
        URLProtocolMock.stubbedRequestHandler = { request in
            guard 
                let url = request.url,
                let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true),
                urlComponents.host == ServerConstants.hostURL.absoluteString
            else {
                return ErrorResponseProvider.provide400Error()
            }
            
            switch urlComponents.path {
            case "/auth/login":
                return try LoginResponseProvider.provide()
            case "/pagination/list":
                return try PaginationResponseProvider.provide(for: request)
            case "/group/header":
                return try GroupResponseProvider.provideHeader()
            case "/group/body":
                return try GroupResponseProvider.provideBody()
            case "/group/footer":
                return try GroupResponseProvider.provideFooter()
            default:
                break
            }
            
            return ErrorResponseProvider.provide400Error()
        }
    }
}
