//
//  MultipartFormDataMock.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 05.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import Foundation
import NodeKit
import NodeKitThirdParty

public class MultipartFormDataMock: MultipartFormDataProtocol {
    
    public struct AppendURLParameters {
        public let fileURL: URL
        public let name: String
    }
    
    public struct AppendCustomURLParameters {
        public let fileURL: URL
        public let name: String
        public let fileName: String
        public let mimeType: String
    }
    
    public struct AppendDataParameters {
        public let data: Data
        public let name: String
        public let fileName: String?
        public let mimeType: String?
    }
    
    public init() { }
    
    public var invokedSetContentType = false
    public var invokedSetContentTypeCount = 0
    public var invokedSetContentTypeParameter: String?
    public var invokedSetContentTyptParameterList: [String] = []
    public var stubbedContentTypeResult: String!

    public var contentType: String {
        get {
            return stubbedContentTypeResult
        }
        
        set(newValue) {
            invokedSetContentType = true
            invokedSetContentTypeCount += 1
            invokedSetContentTypeParameter = newValue
            invokedSetContentTyptParameterList.append(newValue)
        }
    }
    
    public var invokedAppendURL = false
    public var invokedAppendURLCount = 0
    public var invokedAppendURLParameters: AppendURLParameters?
    public var invokedAppendURLParametersList: [AppendURLParameters] = []
    
    public func append(_ fileURL: URL, withName name: String) {
        let parameters = AppendURLParameters(fileURL: fileURL, name: name)
        invokedAppendURL = true
        invokedAppendURLCount += 1
        invokedAppendURLParameters = parameters
        invokedAppendURLParametersList.append(parameters)
    }
    
    public var invokedAppendCustomURL = false
    public var invokedAppendCustomURLCount = 0
    public var invokedAppendCustomURLParameters: AppendCustomURLParameters?
    public var invokedAppendCustomURLParametersList: [AppendCustomURLParameters] = []
    
    public func append(_ fileURL: URL, withName name: String, fileName: String, mimeType: String) {
        let parameters = AppendCustomURLParameters(fileURL: fileURL, name: name, fileName: fileName, mimeType: mimeType)
        invokedAppendCustomURL = true
        invokedAppendCustomURLCount += 1
        invokedAppendCustomURLParameters = parameters
        invokedAppendCustomURLParametersList.append(parameters)
    }
    
    public var invokedAppendData = false
    public var invokedAppendDataCount = 0
    public var invokedAppendDataParameters: AppendDataParameters?
    public var invokedAppendDataParametersList: [AppendDataParameters] = []
    
    public func append(_ data: Data, withName name: String, fileName: String?, mimeType: String?) {
        let parameters = AppendDataParameters(data: data, name: name, fileName: fileName, mimeType: mimeType)
        invokedAppendData = true
        invokedAppendDataCount += 1
        invokedAppendDataParameters = parameters
        invokedAppendDataParametersList.append(parameters)
    }
    
    public var invokedEncode = false
    public var invokedEncodeCount = 0
    public var stubbedEncodeResult: Result<Data, Error>!
    
    public func encode() throws -> Data {
        invokedEncode = true
        invokedEncodeCount += 1
        switch stubbedEncodeResult! {
        case .success(let data):
            return data
        case .failure(let error):
            throw error
        }
    }
}
