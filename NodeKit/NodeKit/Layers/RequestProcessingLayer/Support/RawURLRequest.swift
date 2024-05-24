//
//  RawURLRequest.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 23/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// Обертка над URLRequest.
public struct URLNetworkRequest {
    /// Данные запроса.
    public let urlRequest: URLRequest
    
    public init(urlRequest: URLRequest) {
        self.urlRequest = urlRequest
    }
}

/// Обертка над `Alamofire.DataRequest`
public struct RawURLRequest {

    /// Alamifire запрос.
    public let dataRequest: URLRequest?
    
    public init(dataRequest: URLRequest?) {
        self.dataRequest = dataRequest
    }

    /// Конвертирвет себя в `URLNetworkRequest`
    ///
    /// - Returns: Новое представление запроса.
    public func toURLRequest() -> URLNetworkRequest? {
        guard let request = dataRequest else {
            return nil
        }
        return URLNetworkRequest(urlRequest: request)
    }

}
