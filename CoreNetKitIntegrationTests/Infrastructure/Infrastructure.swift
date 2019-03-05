//
//  Infrastructure.swift
//  CoreNetKitIntegrationTests
//
//  Created by Александр Кравченков on 28/01/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

@testable
import CoreNetKit

public final class Infrastructure {
    public static let baseURL = URL(string: "http://127.0.0.1:8811")!

    public static let getUsersURL = URL(string: "users", relativeTo: baseURL)!

    public static let getEmptyUserArray = URL(string: "userAmptyArr", relativeTo: baseURL)!
    public static let getEmptyUsersWith402 = URL(string: "Get402UserArr", relativeTo: baseURL)!

    public static let authWithFormUrl = URL(string: "authWithFormUrl", relativeTo: baseURL)!
}

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
        return URL(string: "http://127.0.0.1:8811")
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
