//
//  CacheAdapter.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 15.10.2017.
//  Copyright © 2017 Кравченков Александр. All rights reserved.
//

import Foundation

public protocol CacheAdapter {

    func save(urlResponse: URLResponse, urlRequest: URLRequest, data: Data)

    func load(urlRequest: URLRequest, response: CoreServerResponse?) -> CoreServerResponse

    /// Method to adapt Requests for cache needs
    ///
    /// - Parameter request: request to adapt
    /// - Returns: adapted request
    func configure(_ request: CacheConfigurableRequest) -> CacheConfigurableRequest

}

extension CacheAdapter {
    public func configure(_ request: CacheConfigurableRequest) -> CacheConfigurableRequest {
        return request
    }
}
