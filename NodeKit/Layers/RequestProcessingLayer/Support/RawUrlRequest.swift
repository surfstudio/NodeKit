//
//  RawUrlRequest.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 23/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// Обертка над URLRequest.
public struct UrlNetworkRequest {
    /// Данные запроса.
    public let urlRequest: URLRequest
    
    public init(urlRequest: URLRequest) {
        self.urlRequest = urlRequest
    }
}

///// Обертка над `Alamofire.DataRequest`
public struct RawUrlRequest {

    /// Alamifire запрос.
    public let dataRequest: URLRequest?

    public init(dataRequest: URLRequest?) {
        self.dataRequest = dataRequest
    }

    /// Конвертирвет себя в `UrlNetworkRequest`
    ///
    /// - Returns: Новое представление запроса.
    public func toUrlRequest() -> UrlNetworkRequest? {
        guard let request = dataRequest else {
            return nil
        }
        return UrlNetworkRequest(urlRequest: request)
    }

}
