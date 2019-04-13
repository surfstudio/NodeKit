//
//  Utls.swift
//  CoreNetKitUnitTests
//
//  Created by Александр Кравченков on 05/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation
import Alamofire

@testable
import CoreNetKit

enum Utils {
    static func getMockUrlProcessedResponse(url: URL,
                                            statusCode: Int = 200,
                                            httpVersion: String = "1.1",
                                            headers: [String: String] = [:],
                                            data: Data = Data(),
                                            json: Json = Json()) -> UrlProcessedResponse {
        let httpResponse = HTTPURLResponse(url: url,
                                           statusCode: statusCode,
                                           httpVersion: httpVersion,
                                           headerFields: headers)!

        let dataResponse = UrlDataResponse(request: URLRequest(url: url),
                                           response: httpResponse,
                                           data: Data(),
                                           metrics: nil,
                                           serializationDuration: 0)

        return UrlProcessedResponse(dataResponse: dataResponse, json: json)
    }

    static func getMockUrlDataResponse(url: URL,
                                       statusCode: Int = 200,
                                       httpVersion: String = "1.1",
                                       headers: [String: String] = [:],
                                       data: Data = Data()) -> UrlDataResponse{
        let httpResponse = HTTPURLResponse(url: url,
                                           statusCode: statusCode,
                                           httpVersion: httpVersion,
                                           headerFields: headers)!

        return UrlDataResponse(request: URLRequest(url: url),
                                           response: httpResponse,
                                           data: Data(),
                                           metrics: nil,
                                           serializationDuration: 0)
    }
}
