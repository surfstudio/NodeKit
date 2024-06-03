//
//  URLRouting.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 03/04/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// Contains errors for routing URL requests.
///
/// - cantBuildURL: Occurs when it is not possible to build a URL.
public enum URLRouteError: Error {
    case cantBuildURL
}

public extension Optional where Wrapped == URL {

    /// String and URL concatenation operation.
    ///
    /// - Parameters:
    ///   - lhs: The base URL to which the final URL should be relative.
    ///   - rhs: The relative path to be added to the base URL.
    /// - Returns: The final URL route.
    /// - Throws: `URLRouteError.cantBuildURL`
    static func + (lhs: URL?, rhs: String) throws -> URL {
        guard let url = lhs?.appendingPathComponent(rhs) else {
            throw URLRouteError.cantBuildURL
        }
        return url
    }
}

/// An extension for conveniently wrapping `URLRouteProvider`.
/// - Warning:
/// This is used exclusively for communication between nodes.
extension URL: URLRouteProvider {
    /// Returns self
    public func url() throws -> URL {
        return self
    }
}
