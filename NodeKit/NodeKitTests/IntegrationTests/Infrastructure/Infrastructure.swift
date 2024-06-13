//
//  Infrastructure.swift
//  CoreNetKitIntegrationTests
//
//  Created by Александр Кравченков on 28/01/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

@testable import NodeKit

public enum Routes {

    public enum Exception: Error {
        case badURL
    }

    case users
    case emptyUsers
    case emptyUsersWith204
    case authWithFormURL
    case multipartPing
}

extension Routes: URLRouteProvider {

    private static var base: URL? {
        return URL(string: "http://localhost:8118/nkt")
    }

    public func url() throws -> URL {
        guard let url = self.tryToGetURL() else {
            throw Exception.badURL
        }

        return url
    }

    private func tryToGetURL() -> URL? {
        switch self {
        case .users:
            return try? Routes.base + "/users"
        case .emptyUsers:
            return try? Routes.base + "/userEmptyArr"
        case .emptyUsersWith204:
            return try? Routes.base + "/Get204UserArr"
        case .authWithFormURL:
            return try? Routes.base + "/authWithFormURL"
        case .multipartPing:
            return try? Routes.base + "/multipartPing"
        }
    }
}
