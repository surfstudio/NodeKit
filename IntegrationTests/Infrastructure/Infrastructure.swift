//
//  Infrastructure.swift
//  CoreNetKitIntegrationTests
//
//  Created by Александр Кравченков on 28/01/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

@testable
import NodeKit

public enum Routes {

    public enum Exception: Error {
        case badUrl
    }

    case users
    case emptyUsers
    case emptyUsersWith402
    case authWithFormUrl
}

extension Routes: UrlRouteProvider {

    private static var base: URL? {
        return URL(string: "http://localhost:8844")
    }

    public func url() throws -> URL {
        guard let url = self.tryToGetUrl() else {
            throw Exception.badUrl
        }

        return url
    }

    private func tryToGetUrl() -> URL? {
        switch self {
        case .users:
            return Routes.base + "users"
        case .emptyUsers:
            return Routes.base + "userAmptyArr"
        case .emptyUsersWith402:
            return Routes.base + "Get402UserArr"
        case .authWithFormUrl:
            return Routes.base + "authWithFormUrl"
        }
    }
}

extension Optional where Wrapped == URL {
    public static func + (lhs: URL?, rhs: String) -> URL? {
        return URL(string: rhs, relativeTo: lhs)
    }
}
