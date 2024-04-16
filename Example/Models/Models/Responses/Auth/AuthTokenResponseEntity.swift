//
//  AuthTokenResponseEntity.swift
//
//  Created by Andrei Frolov on 11.04.24.
//

import Foundation
import NodeKit

public struct AuthTokenResponseEntity {
    
    // MARK: - Properties
    
    public let accessToken: String
    public let refreshToken: String
    
    // MARK: - Initialization
    
    public init(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
}

extension AuthTokenResponseEntity: DTOConvertible {
    public typealias DTO = AuthTokenResponseEntry
    
    public func toDTO() throws -> AuthTokenResponseEntry {
        return AuthTokenResponseEntry(accessToken: accessToken, refreshToken: refreshToken)
    }
    
    public static func from(dto: AuthTokenResponseEntry) throws -> AuthTokenResponseEntity {
        return AuthTokenResponseEntity(accessToken: dto.accessToken, refreshToken: dto.refreshToken)
    }
}
