//
//  URLResponsesStub.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 09.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit
@testable import NodeKitMock
@testable import NodeKitThirdParty

import Foundation

public enum URLResponsesStub {
    
    public static func stubIntegrationTestsResponses() {
        URLProtocolMock.stubbedRequestHandler = { request in
            guard
                let url = request.url,
                let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true),
                urlComponents.scheme == "http",
                urlComponents.host == "localhost",
                urlComponents.port == 8118,
                urlComponents.path.split(separator: "/").count == 2,
                urlComponents.path.split(separator: "/")[0] == "nkt"
            else {
                throw MockError.firstError
            }
            
            switch urlComponents.path.split(separator: "/")[1] {
            case "users":
                return try makeUsersResponse(request: request)
            case "userEmptyArr":
                return try makeUserEmptyArrResponse(request: request)
            case "Get204UserArr":
                return try makeGet204UserArrResponse(request: request)
            case "authWithFormURL":
                return try makeAuthWithFormURLResponse(request: request)
            case "multipartPing":
                return try makeMultipartPingResponse(request: request)
            default:
                throw MockError.firstError
            }
        }
    }
    
    public static func flush() {
        URLProtocolMock.flush()
    }
}

// MARK: - Private Methods

private extension URLResponsesStub {
    
    private static func makeUsersResponse(request: URLRequest) throws -> (HTTPURLResponse, Data) {
        guard
            let url = request.url,
            request.httpMethod == Method.get.rawValue,
            request.httpBody == nil
        else {
            return (
                HTTPURLResponse(
                    url: request.url!,
                    statusCode: 400,
                    httpVersion: nil,
                    headerFields: nil
                )!,
                Data()
            )
        }
        
        var users: [User] = []
        
        let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: true)?.queryItems
        let sortQuery = queryItems?.first(where: { $0.name == "sort" })
        let stackQuery = queryItems?.first(where: { $0.name == "stack" })
        
        if sortQuery?.value == "false", stackQuery?.value == "left" {
            users.append(User(id: "id0", firstName: "Rodrigez0", lastName: "Bender0"))
            users.append(User(id: "id1", firstName: "Rodrigez1", lastName: "Bender1"))
            users.append(User(id: "id2", firstName: "Rodrigez2", lastName: "Bender2"))
            users.append(User(id: "id3", firstName: "Rodrigez3", lastName: "Bender3"))
        } else {
            users.append(User(id: "id0", firstName: "Philip0", lastName: "Fry0"))
            users.append(User(id: "id1", firstName: "Philip1", lastName: "Fry1"))
            users.append(User(id: "id2", firstName: "Philip2", lastName: "Fry2"))
            users.append(User(id: "id3", firstName: "Philip3", lastName: "Fry3"))
        }
        
        let json = try users.toDTO().toRaw()
        let data = try JSONSerialization.data(withJSONObject: json)
        
        return (
            HTTPURLResponse(
                url: url,
                mimeType: nil,
                expectedContentLength: 0,
                textEncodingName: nil
            ),
            data
        )
    }
    
    private static func makeUserEmptyArrResponse(request: URLRequest) throws -> (HTTPURLResponse, Data) {
        guard
            let url = request.url,
            request.httpMethod == Method.get.rawValue,
            request.httpBody == nil
        else {
            return (
                HTTPURLResponse(
                    url: request.url!,
                    statusCode: 400,
                    httpVersion: nil,
                    headerFields: nil
                )!,
                Data()
            )
        }
        
        let users: [User] = []
        let json = try users.toDTO().toRaw()
        let data = try JSONSerialization.data(withJSONObject: json)
        
        return (
            HTTPURLResponse(
                url: url,
                mimeType: nil,
                expectedContentLength: 0,
                textEncodingName: nil
            ),
            data
        )
    }
    
    private static func makeGet204UserArrResponse(request: URLRequest) throws -> (HTTPURLResponse, Data) {
        return (
            HTTPURLResponse(
                url: request.url!,
                statusCode: 204,
                httpVersion: nil,
                headerFields: nil
            )!,
            Data()
        )
    }
    
    private static func makeAuthWithFormURLResponse(request: URLRequest) throws -> (HTTPURLResponse, Data) {
        guard
            let url = request.url,
            let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: true)?.queryItems,
            queryItems.count == 2,
            queryItems.contains(where: { $0.name == "type" }),
            queryItems.contains(where: { $0.name == "secret" }),
            request.httpMethod == Method.post.rawValue,
            request.httpBody == nil,
            request.allHTTPHeaderFields == [:]
        else {
            return (
                HTTPURLResponse(
                    url: request.url!,
                    statusCode: 400,
                    httpVersion: nil,
                    headerFields: nil
                )!,
                Data()
            )
        }
        
        let json = try Credentials(
            accessToken: "stubbedAccessToken",
            refreshToken: "stubbedRefreshToken"
        ).toDTO().toRaw()
        
        let data = try JSONSerialization.data(withJSONObject: json)
        
        return (
            HTTPURLResponse(
                url: url,
                mimeType: nil,
                expectedContentLength: 0,
                textEncodingName: nil
            ),
            data
        )
    }
    
    private static func makeMultipartPingResponse(request: URLRequest) throws -> (HTTPURLResponse, Data) {
        guard
            let url = request.url,
            URLComponents(url: url, resolvingAgainstBaseURL: true)?.queryItems == nil,
            request.httpMethod == Method.post.rawValue,
            request.httpBody == nil,
            let stream = request.httpBodyStream,
            let headers = request.allHTTPHeaderFields,
            headers.count == 2,
            headers["Content-Type"]?.contains("multipart/form-data") == true,
            let contentLengthString = headers["Content-Length"],
            !contentLengthString.isEmpty,
            let contentLengthInt = Int(contentLengthString)
        else {
            return (
                HTTPURLResponse(
                    url: request.url!,
                    statusCode: 400,
                    httpVersion: nil,
                    headerFields: nil
                )!,
                Data()
            )
        }
        
        let multipartFormData = MultipartFormData()
        multipartFormData.append(stream, withLength: UInt64(contentLengthInt), headers: request.headers)
        
        _ = try multipartFormData.encode()
        
        let json = ["success": true]
        let data = try JSONSerialization.data(withJSONObject: json)
        
        return (
            HTTPURLResponse(
                url: url,
                mimeType: nil,
                expectedContentLength: 0,
                textEncodingName: nil
            ),
            data
        )
    }
}
