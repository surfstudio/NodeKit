//
//  TokenEntity.swift
//  CoreNetKitIntegrationTests
//
//  Created by Александр Кравченков on 04/02/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

@testable
import CoreNetKit

public struct Credentials {
    public let accessToken: String
    public let refreshToken: String
}

extension Credentials: DTOConvertible {

    public typealias DTO = CredentialsEntry

    public static func toModel(from entry: CredentialsEntry) throws -> Credentials {
        return Credentials(accessToken: entry.accessToken, refreshToken: entry.refreshToken)
    }

    public func toDTO() throws -> CredentialsEntry {
        return CredentialsEntry(accessToken: self.accessToken, refreshToken: self.refreshToken)
    }
}
