//
//  URLCacheReaderNode.swift
//  CoreNetKitWithExample
//
//  Created by Александр Кравченков on 28/11/2018.
//  Copyright © 2018 Александр Кравченков. All rights reserved.
//

import Foundation

/// Errors for the ``URLCacheReaderNode``
///
/// - cantLoadDataFromCache: Occurs if the request to the cache failed
/// - cantSerializeJson: Occurs if the request to the cache succeeded, but failed to serialize the response into JSON
/// - cantCastToJson: Occurs if serialization of the response succeeded, but casting to ``Json`` or [``Json``] failed
public enum BaseURLCacheReaderError: Error {
    case cantLoadDataFromCache
    case cantSerializeJson
    case cantCastToJson
}

/// This node is responsible for reading data from the URL cache.
/// The node itself is a leaf and cannot be embedded in a pass-through chain.
open class URLCacheReaderNode: AsyncNode {

    /// Sends a request to the cache and tries to serialize the data into JSON.
    open func process(
        _ data: URLNetworkRequest,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<Json> {
        await .withCheckedCancellation {
            guard let cachedResponse = extractCachedURLResponse(data.urlRequest) else {
                return .failure(BaseURLCacheReaderError.cantLoadDataFromCache)
            }

            guard let jsonObjsect = try? JSONSerialization.jsonObject(
                with: cachedResponse.data,
                options: .allowFragments
            ) else {
                return .failure(BaseURLCacheReaderError.cantSerializeJson)
            }

            guard let json = jsonObjsect as? Json else {
                guard let json = jsonObjsect as? [Json] else {
                    return .failure(BaseURLCacheReaderError.cantCastToJson)
                }
                return .success([MappingUtils.arrayJsonKey: json])
            }

            return .success(json)
        }
    }

    private func extractCachedURLResponse(_ request: URLRequest) -> CachedURLResponse? {
        if let response = URLCache.shared.cachedResponse(for: request) {
            return response
        }
        return nil
    }
}
