//
//  Utls.swift
//  CoreNetKitUnitTests
//
//  Created by Александр Кравченков on 05/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

@testable import NodeKit

enum Utils {
    static func getMockURLProcessedResponse(url: URL,
                                            statusCode: Int = 200,
                                            httpVersion: String = "1.1",
                                            headers: [String: String] = [:],
                                            data: Data = Data(),
                                            json: Json = Json()) -> URLProcessedResponse {
        let httpResponse = HTTPURLResponse(url: url,
                                           statusCode: statusCode,
                                           httpVersion: httpVersion,
                                           headerFields: headers)!

        let dataResponse = URLDataResponse(request: URLRequest(url: url),
                                           response: httpResponse,
                                           data: Data())

        return URLProcessedResponse(dataResponse: dataResponse, json: json)
    }

    static func getMockURLDataResponse(url: URL,
                                       statusCode: Int = 200,
                                       httpVersion: String = "1.1",
                                       headers: [String: String] = [:],
                                       data: Data = Data()) -> URLDataResponse{
        let httpResponse = HTTPURLResponse(url: url,
                                           statusCode: statusCode,
                                           httpVersion: httpVersion,
                                           headerFields: headers)!

        return URLDataResponse(request: URLRequest(url: url),
                                           response: httpResponse,
                                           data: Data())
    }
}
