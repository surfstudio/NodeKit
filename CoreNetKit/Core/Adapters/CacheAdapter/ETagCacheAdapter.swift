//
//  ETagCacheAdapter.swift
//  CoreNetKit
//
//  Created by Serge Nanaev on 26.04.2018.
//  Copyright © 2018 Кравченков Александр. All rights reserved.
//

import Foundation

open class ETagCacheAdapter: CacheAdapter {

    // MARK: - Constants

    fileprivate enum Constants {
        static let eTagApiHeaderField: String = "ETag"
        static let noneMatchApiHeaderField: String = "If-None-Match"
    }

    // MARK: - Initialization and deinitialization

    public init() { }

    // MARK: - CacheAdapter

    open func save(urlResponse: URLResponse, urlRequest: URLRequest, data: Data) {
        let cahced = CachedURLResponse(response: urlResponse, data: data, storagePolicy: .allowed)
        self.updateETag(for: urlResponse)
        URLCache.shared.storeCachedResponse(cahced, for: urlRequest)
    }

    open func load(urlRequest: URLRequest, response: CoreServerResponse?) -> CoreServerResponse {
        var result = response ?? BaseCoreServerResponse()

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

    open func configure(_ request: URLRequest) -> URLRequest {
        guard let urlString = request.url?.absoluteString, let eTag = getETag(for: urlString) else {
            return request
        }
        var eTagReadyRequest = request
        eTagReadyRequest.allHTTPHeaderFields?[Constants.noneMatchApiHeaderField] = eTag
        return eTagReadyRequest
    }
}

//MARK: - Private helpers

private extension ETagCacheAdapter {
    func extractCachedUrlResponse(request: URLRequest) -> CachedURLResponse? {
        if let response = URLCache.shared.cachedResponse(for: request) {
            return response
        }
        return nil
    }

    func updateETag(for urlResponse: URLResponse) {
        if let httpResponse = urlResponse as? HTTPURLResponse,
            let urlString = httpResponse.url?.absoluteString,
            let etag = httpResponse.allHeaderFields[Constants.eTagApiHeaderField] as? String {
            // save the etag header value with the url as a key.
            UserDefaults.standard.set(etag, forKey: urlString)
        }
    }

    func getETag(for urlString: String) -> String? {
        // return the saved ETag value for the given URL
        return UserDefaults.standard.object(forKey: urlString) as? String
    }
}
