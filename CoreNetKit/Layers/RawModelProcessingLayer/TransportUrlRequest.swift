//
//  TransportUrlRequest.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 16/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

public struct TransportUrlRequest {
    let method: Method
    let url: URL
    let headers: [String: String]
    let raw: Json
    let parametersEncoding: ParametersEncoding

    public init(with params: TransportUrlParameters, raw: Json) {
        self.method = params.method
        self.url = params.url
        self.headers = params.headers
        self.raw = raw
        self.parametersEncoding = params.parametersEncoding
    }
}
