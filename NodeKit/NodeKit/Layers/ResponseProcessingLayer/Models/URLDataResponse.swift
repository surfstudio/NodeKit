//
//  URLDataResponse.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 04/02/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// Server response model.
/// Used for passing information within the response handling chain.
public struct URLDataResponse: Equatable {
    /// The request sent to the server.
    public let request: URLRequest
    /// The response received from the server.
    public let response: HTTPURLResponse
    /// The data returned by the server.
    public let data: Data

    public init(request: URLRequest,
                response: HTTPURLResponse,
                data: Data) {
        self.request = request
        self.response = response
        self.data = data
    }
}
