//
//  PaginationURLProvider.swift
//
//
//  Created by Andrei Frolov on 15.04.24.
//

import Foundation
import NodeKit

enum PaginationURLProvider: URLRouteProvider {
    private static var base: URLRouteProvider = NavigationURLProvider.pagination
    
    case list
    
    func url() throws -> URL {
        switch self {
        case .list:
            return try Self.base.url() + "/list"
        }
    }
}
