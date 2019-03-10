//
//  ChainImputModel.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 10/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

public struct ChainConfigModel {
    public let method: Method
    public let route: UrlRouteProvider
    public let metadata: [String: String]
    public let encoding: ParametersEncoding

    public init(method: Method,
         route: UrlRouteProvider,
         metadata: [String: String] = [:],
         encoding: ParametersEncoding = .json) {
        self.method = method
        self.route = route
        self.metadata = metadata
        self.encoding = encoding
    }
}
