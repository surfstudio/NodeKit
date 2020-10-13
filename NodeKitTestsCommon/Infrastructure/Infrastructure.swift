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
    case multipartPing
    case multipartCorrect
    case multipartFile
    case bson
}

extension Routes: UrlRouteProvider {

    private static var base: URL? {
        return URL(string: "http://localhost:8118/nkt")
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
            return try? Routes.base + "/users"
        case .emptyUsers:
            return try? Routes.base + "/userAmptyArr"
        case .emptyUsersWith402:
            return try? Routes.base + "/Get402UserArr"
        case .authWithFormUrl:
            return try? Routes.base + "/authWithFormUrl"
        case .multipartPing:
            return try? Routes.base + "/multipartPing"
        case .multipartCorrect:
            return try? Routes.base + "/multipartCorrect"
        case .multipartFile:
            return try? Routes.base + "/multipartFile"
        case .bson:
            return try? Routes.base + "/bson"
        }
    }
}
