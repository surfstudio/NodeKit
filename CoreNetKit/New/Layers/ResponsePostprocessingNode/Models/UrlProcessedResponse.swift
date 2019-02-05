//
//  UrlProcessedResponse.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 04/02/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation
import Alamofire

/// View used for trasfer data inside response postprocessing layer
public struct UrlProcessedResponse {

    private let _dataResponse: UrlDataResponse

    /// The URL request sent to the server.
    public var request: URLRequest {
        return self._dataResponse.request
    }

    /// The server's response to the URL request.
    public var response: HTTPURLResponse {
        return self._dataResponse.response
    }

    /// The timeline of the complete lifecycle of the request.
    public var timeline: Timeline {
        return self._dataResponse.timeline
    }

    /// The data returned by the server.
    public var data: Data {
        return self._dataResponse.data
    }

    /// JSON parsed from the server's response
    public let json: Json

    public init(dataResponse: UrlDataResponse, json: Json) {
        self._dataResponse = dataResponse
        self.json = json
    }
}
