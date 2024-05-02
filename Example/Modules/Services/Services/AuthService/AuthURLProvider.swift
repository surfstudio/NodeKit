//
//  AuthURLProvider.swift
//
//
//  Created by Andrei Frolov on 15.04.24.
//

import Foundation
import NodeKit

enum AuthURLProvider: UrlRouteProvider {
    private static var base: UrlRouteProvider = NavigationURLProvider.auth
    
    case login
    case logout
    
    func url() throws -> URL {
        switch self {
        case .login:
            return try Self.base.url() + "/login"
        case .logout:
            return try Self.base.url() + "/logout"
        }
    }
}
