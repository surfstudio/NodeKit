//
//  AuthURLProvider.swift
//
//
//  Created by Andrei Frolov on 15.04.24.
//

import Foundation
import NodeKit

enum AuthURLProvider: URLRouteProvider {
    private static var base: URLRouteProvider = NavigationURLProvider.auth
    
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
