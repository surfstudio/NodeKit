//
//  TransportURLParameters.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 16/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// Model for passing parameters at the transport layer of the chain.
public struct TransportURLParameters {
    /// HTTP method.
    public let method: Method
    /// URL endpoint.
    public let url: URL
    /// Request headers.
    public let headers: [String: String]

    /// Initializes the object.
    ///
    /// - Parameters:
    ///   - method: HTTP method.
    ///   - url: URL endpoint.
    ///   - headers: Request headers.
    public init(method: Method, url: URL, headers: [String: String] = [:]) {
        self.method = method
        self.url = url
        self.headers = headers
    }

}
