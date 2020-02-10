//
//  RawUrlRequest.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 23/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation
import Alamofire

/// Обертка над URLRequest.
public struct UrlNetworkRequest {
    /// Данные запроса.
    public let urlRequest: URLRequest
    
    public init(urlRequest: URLRequest) {
        self.urlRequest = urlRequest
    }
}

/// Обертка над `Alamofire.DataRequest`
public struct RawUrlRequest {

    /// Alamifire запрос.
    public let dataRequest: DataRequest
    
    public init(dataRequest: DataRequest) {
        self.dataRequest = dataRequest
    }

    /// Конвертирвет себя в `UrlNetworkRequest`
    ///
    /// - Returns: Новое представление запроса.
    public func toUrlRequest() -> UrlNetworkRequest? {
        do {
            let urlRequest = try self.dataRequest.convertible.asURLRequest()
            return UrlNetworkRequest(urlRequest: urlRequest)
        } catch {
            return nil
        }
    }
}
