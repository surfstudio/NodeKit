//
//  UrlCacheReaderNode.swift
//  CoreNetKitWithExample
//
//  Created by Александр Кравченков on 28/11/2018.
//  Copyright © 2018 Александр Кравченков. All rights reserved.
//

import Foundation
import Alamofire

enum BaseUrlCacheReaderError: Error {
    case cantLoadDataFromCache
}

struct UrlNetworkRequest {
    let urlRequest: URLRequest
}

class UrlCacheReaderNode: Node<UrlNetworkRequest, CoreNetKitJson> {
    override func input(_ data: UrlNetworkRequest) -> Context<CoreNetKitJson> {
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


    func extractCachedUrlResponse(request: URLRequest) -> CachedURLResponse? {
        if let response = URLCache.shared.cachedResponse(for: request) {
            return response
        }
        return nil
    }
}
