//
//  GroupURLProvider.swift
//
//
//  Created by Andrei Frolov on 15.04.24.
//

import Foundation
import NodeKit

enum GroupURLProvider: UrlRouteProvider {
    private static var base: UrlRouteProvider = NavigationURLProvider.group
    
    case header
    case body
    case footer
    
    func url() throws -> URL {
        switch self {
        case .header:
            return try Self.base.url() + "/header"
        case .body:
            return try Self.base.url() + "/body"
        case .footer:
            return try Self.base.url() + "/footer"
        }
    }
}
