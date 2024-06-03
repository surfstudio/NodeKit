//
//  RawURLRequest.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 23/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// URLRequest wrapper.
public struct URLNetworkRequest {
    /// Request data.
    public let urlRequest: URLRequest
    
    public init(urlRequest: URLRequest) {
        self.urlRequest = urlRequest
    }
}

/// `Alamofire.DataRequest` wrapper.
public struct RawURLRequest {

    /// Alamifire request.
    public let dataRequest: URLRequest?
    
    public init(dataRequest: URLRequest?) {
        self.dataRequest = dataRequest
    }

    /// Converts itself into `URLNetworkRequest`.
    ///
    /// - Returns: The new request representation.
    public func toURLRequest() -> URLNetworkRequest? {
        guard let request = dataRequest else {
            return nil
        }
        return URLNetworkRequest(urlRequest: request)
    }

}
