//
//  UrlDataResponse.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 04/02/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation
import Alamofire

/// Custom view of raw response type.
/// Used for trasfer data inside response processing layer.
public struct UrlDataResponse {
    /// The URL request sent to the server.
    public let request: URLRequest
    /// The server's response to the URL request.
    public let response: HTTPURLResponse
    /// The data returned by the server.
    public let data: Data
    /// The timeline of the complete lifecycle of the request.
    public let timeline: Timeline
}
