//
//  URLProcessedResponse.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 04/02/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// Used to transfer data within the request post-processing layer.
public struct URLProcessedResponse {

    private let _dataResponse: URLDataResponse

    /// URL request sent to the server.
    public var request: URLRequest {
        return self._dataResponse.request
    }

    /// Response received from the server.
    public var response: HTTPURLResponse {
        return self._dataResponse.response
    }

    /// Data, received from the server.
    public var data: Data {
        return self._dataResponse.data
    }

    /// ``Json`` serialized after processing the response.
    public let json: Json

    /// Initializes the object.
    ///
    /// - Parameters:
    ///   - dataResponse: Model ``URLDataResponse`` received after processing the response.
    ///   - json: Serialized ``Json``.
    public init(dataResponse: URLDataResponse, json: Json) {
        self._dataResponse = dataResponse
        self.json = json
    }
}
