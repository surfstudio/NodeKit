//
//  TransportUrlParameters.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 16/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

public struct TransportUrlParameters {
    let method: Method
    let url: URL
    let headers: [String: String]
    let parametersEncoding: ParametersEncoding

    public init(method: Method, url: URL, headers: [String: String] = [:], parametersEncoding: ParametersEncoding = .json) {
        self.method = method
        self.url = url
        self.headers = headers
        self.parametersEncoding = parametersEncoding
    }
}
