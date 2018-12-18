//
//  UrlCacheReaderNode.swift
//  CoreNetKitWithExample
//
//  Created by Александр Кравченков on 28/11/2018.
//  Copyright © 2018 Александр Кравченков. All rights reserved.
//

import Foundation
import Alamofire

public enum BaseUrlCacheReaderError: Error {
    case cantLoadDataFromCache
}

public struct UrlNetworkRequest {
    let urlRequest: URLRequest
}

open class UrlCacheReaderNode: Node<UrlNetworkRequest, CoreNetKitJson> {
    open override func process(_ data: UrlNetworkRequest) -> Context<CoreNetKitJson> {
        let result = Context<CoreNetKitJson>()

        if let cachedResponse = self.extractCachedUrlResponse(request: data.urlRequest),
            let object = try? JSONSerialization.jsonObject(with: cachedResponse.data, options: .allowFragments),
            let json = object as? CoreNetKitJson {
                result.emit(data: json)
        } else {
            result.emit(error: BaseUrlCacheReaderError.cantLoadDataFromCache)
        }
        return result
    }


   private func extractCachedUrlResponse(request: URLRequest) -> CachedURLResponse? {
        if let response = URLCache.shared.cachedResponse(for: request) {
            return response
        }
        return nil
    }
}
