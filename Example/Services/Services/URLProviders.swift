//
//  URLProviders.swift
//
//  Created by Andrei Frolov on 15.04.24.
//

import Foundation
import NodeKit

enum RootURLProvider: UrlRouteProvider {
    case root
    
    func url() throws -> URL {
        return URL(string: "http://www.mockurl.com")!
    }
}

enum NavigationURLProvider: UrlRouteProvider {
    private static var base: UrlRouteProvider = RootURLProvider.root
    
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
