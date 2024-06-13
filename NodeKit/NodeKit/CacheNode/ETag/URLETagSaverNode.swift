//
//  eTagSaverNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 04/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

// MARK: - UserDefaults eTag storage

/// Reference to the UserDefaults storage for eTag tokens.
extension UserDefaults {
    /// Storage for eTag tokens
    static var etagStorage = UserDefaults(suiteName: "\(String(describing: UserDefaults.self))")
}

/// This node stores received eTag tokens.
/// The absolute URL to the endpoint is used as the key.
open class URLETagSaverNode: AsyncNode {

    /// The next node for processing.
    public var next: (any ResponsePostprocessorLayerNode)?

    /// The key to retrieve the eTag token from the headers.
    /// The default value is `ETagConstants.eTagResponseHeaderKey`.
    public var eTagHeaderKey: String

    /// Initializer.
    ///
    /// - Parameters:
    ///   - next: The next node for processing.
    ///   - eTagHeaderKey: The key to retrieve the eTag token from the headers.
    public init(next: (any ResponsePostprocessorLayerNode)?, eTagHeaderKey: String = ETagConstants.eTagResponseHeaderKey) {
        self.next = next
        self.eTagHeaderKey = eTagHeaderKey
    }

    /// Tries to retrieve the eTag token by the key.
    /// In any case, passes control further.
    open func process(
        _ data: URLProcessedResponse,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<Void> {
        await .withCheckedCancellation {
            guard let tag = data.response.allHeaderFields[self.eTagHeaderKey] as? String,
                let url = data.request.url,
                let urlAsKey = url.withOrderedQuery()
            else {
                return await next?.process(data, logContext: logContext) ?? .success(())
            }

            UserDefaults.etagStorage?.set(tag, forKey: urlAsKey)

            return await next?.process(data, logContext: logContext) ?? .success(())
        }
    }
}

public extension URL {

    /// Takes the original URL
    /// Gets dictionary of query parameters
    /// If there are no parameters - returns `self.absoluteString`
    /// If parameters exist - sorts them and joins them into one string
    /// Removes query parameters from the original URL
    /// Concatenates the string representation of the URL without parameters with the parameter string
    ///
    /// **IMPORTANT**
    ///
    /// The resulting string may be an invalid URL - since the purpose of this method is to extract a unique identifier from the URL
    /// Moreover, the order of query parameters does not matter.
    func withOrderedQuery() -> String? {
        guard var comp = URLComponents(string: self.absoluteString) else {
            return nil
        }

        // If there are no query parameters, return this URL because there is nothing to sort.
        if comp.queryItems == nil || comp.queryItems?.isEmpty == true {
            return self.absoluteString
        }

        let ordereedQueryString = comp.queryItems!
            .map { $0.description }
            .sorted()
            .reduce("", { $1 + $0 })

        // If you reset the query component to nil, then the resulting URL will not have a query component.
        comp.query = nil

        guard let url = comp.url else {
            return nil
        }

        return url.absoluteString + ordereedQueryString
    }
}
