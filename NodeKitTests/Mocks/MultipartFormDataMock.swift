//
//  MultipartFormDataMock.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 05.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit
@testable import ThirdParty

final class MultipartFormDataMock: MultipartFormDataProtocol {
    
    struct AppendURLParameters {
        let fileUrl: URL
        let name: String
    }
    
    struct AppendCustomURLParameters {
        let fileUrl: URL
        let name: String
        let fileName: String
        let mimeType: String
    }
    
    struct AppendDataParameters {
        let data: Data
        let name: String
        let fileName: String?
        let mimeType: String?
    }
    
    var invokedSetContentType = false
    var invokedSetContentTypeCount = 0
    var invokedSetContentTypeParameter: String?
    var invokedSetContentTyptParameterList: [String] = []
    var stubbedContentTypeResult: String!

    var contentType: String {
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
    
    var invokedAppendURL = false
    var invokedAppendURLCount = 0
    var invokedAppendURLParameters: AppendURLParameters?
    var invokedAppendURLParametersList: [AppendURLParameters] = []
    
    func append(_ fileURL: URL, withName name: String) {
        let parameters = AppendURLParameters(fileUrl: fileURL, name: name)
        invokedAppendURL = true
        invokedAppendURLCount += 1
        invokedAppendURLParameters = parameters
        invokedAppendURLParametersList.append(parameters)
    }
    
    var invokedAppendCustomURL = false
    var invokedAppendCustomURLCount = 0
    var invokedAppendCustomURLParameters: AppendCustomURLParameters?
    var invokedAppendCustomURLParametersList: [AppendCustomURLParameters] = []
    
    func append(_ fileURL: URL, withName name: String, fileName: String, mimeType: String) {
        let parameters = AppendCustomURLParameters(fileUrl: fileURL, name: name, fileName: fileName, mimeType: mimeType)
        invokedAppendCustomURL = true
        invokedAppendCustomURLCount += 1
        invokedAppendCustomURLParameters = parameters
        invokedAppendCustomURLParametersList.append(parameters)
    }
    
    var invokedAppendData = false
    var invokedAppendDataCount = 0
    var invokedAppendDataParameters: AppendDataParameters?
    var invokedAppendDataParametersList: [AppendDataParameters] = []
    
    func append(_ data: Data, withName name: String, fileName: String?, mimeType: String?) {
        let parameters = AppendDataParameters(data: data, name: name, fileName: fileName, mimeType: mimeType)
        invokedAppendData = true
        invokedAppendDataCount += 1
        invokedAppendDataParameters = parameters
        invokedAppendDataParametersList.append(parameters)
    }
    
    var invokedEncode = false
    var invokedEncodeCount = 0
    var stubbedEncodeResult: Result<Data, Error>!
    
    func encode() throws -> Data {
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
