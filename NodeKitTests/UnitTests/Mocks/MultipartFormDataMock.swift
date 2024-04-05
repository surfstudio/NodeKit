//
//  MultipartFormDataMock.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 05.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit

final class MultipartFormDataMock: MultipartFormDataProtocol {
    
    struct ShortFileUrl {
        let fileUrl: URL
        let name: String
    }
    
    struct FullFileUrl {
        let fileUrl: URL
        let name: String
        let fileName: String
        let mimeType: String
    }
    
    struct FullData {
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
    
    var invokedAppendWithShortFileUrl = false
    var invokedAppendWithShortFileUrlCount = 0
    var invokedAppendWithShortFileUrlParameters: ShortFileUrl?
    var invokedAppendWithShortFileUrlParametersList: [ShortFileUrl] = []
    
    func append(_ fileURL: URL, withName name: String) {
        let parameters = ShortFileUrl(fileUrl: fileURL, name: name)
        invokedAppendWithShortFileUrl = true
        invokedAppendWithShortFileUrlCount += 1
        invokedAppendWithShortFileUrlParameters = parameters
        invokedAppendWithShortFileUrlParametersList.append(parameters)
    }
    
    var invokedAppendWithFullFileUrl = false
    var invokedAppendWithFullFileUrlCount = 0
    var invokedAppendWithFullFileUrlParameters: FullFileUrl?
    var invokedAppendWithFullFileUrlParametersList: [FullFileUrl] = []
    
    func append(_ fileURL: URL, withName name: String, fileName: String, mimeType: String) {
        let parameters = FullFileUrl(fileUrl: fileURL, name: name, fileName: fileName, mimeType: mimeType)
        invokedAppendWithFullFileUrl = true
        invokedAppendWithFullFileUrlCount += 1
        invokedAppendWithFullFileUrlParameters = parameters
        invokedAppendWithFullFileUrlParametersList.append(parameters)
    }
    
    var invokedAppendWithFullData = false
    var invokedAppendWithFullDataCount = 0
    var invokedAppendWithFullDataParameters: FullData?
    var invokedAppendWithFullDataParametersList: [FullData] = []
    
    func append(_ data: Data, withName name: String, fileName: String?, mimeType: String?) {
        let parameters = FullData(data: data, name: name, fileName: fileName, mimeType: mimeType)
        invokedAppendWithFullData = true
        invokedAppendWithFullDataCount += 1
        invokedAppendWithFullDataParameters = parameters
        invokedAppendWithFullDataParametersList.append(parameters)
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
