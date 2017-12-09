//
//  UrlCacheAdapter.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 15.10.2017.
//  Copyright © 2017 Кравченков Александр. All rights reserved.
//

import Foundation

open class UrlCacheAdapter: CacheAdapter {

    public init() { }

    open func save(urlResponse: URLResponse, urlRequest: URLRequest, data: Data) {
        let cahced = CachedURLResponse(response: urlResponse, data: data, storagePolicy: .allowed)
        URLCache.shared.storeCachedResponse(cahced, for: urlRequest)
    }

    open func load(urlRequest: URLRequest, response: CoreServerResponse?) -> CoreServerResponse {
        let result = response ?? CoreServerResponse()

        if let cachedResponse = self.extractCachedUrlResponse(request: urlRequest),
            let resultResponse = cachedResponse.response as? HTTPURLResponse {
            result.httpResponse = resultResponse
            result.result = { () -> ResponseResult<Any> in
                do {
                    let object = try JSONSerialization.jsonObject(with: cachedResponse.data, options: .allowFragments)
                    return .success(object, true)
                } catch {
                    return .failure(BaseCacheError.cantLoadFromCache)
                }
            }()
        }
        return result
    }
}

private extension UrlCacheAdapter {
    func extractCachedUrlResponse(request: URLRequest) -> CachedURLResponse? {
        if let response = URLCache.shared.cachedResponse(for: request) {
            return response
        }
        return nil
    }
}
