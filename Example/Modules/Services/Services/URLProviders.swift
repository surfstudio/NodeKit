//
//  URLProviders.swift
//
//  Created by Andrei Frolov on 15.04.24.
//

import Foundation
import NodeKit

enum RootURLProvider: URLRouteProvider {
    case root
    
    func url() throws -> URL {
        return URL(string: "http://www.mockurl.com")!
    }
}

enum NavigationURLProvider: URLRouteProvider {
    private static var base: URLRouteProvider = RootURLProvider.root
    
    case auth
    case pagination
    case group
    
    func url() throws -> URL {
        switch self {
        case .auth:
            return try Self.base.url() + "/auth"
        case .pagination:
            return try Self.base.url() + "/pagination"
        case .group:
            return try Self.base.url() + "/group"
        }
    }
}
