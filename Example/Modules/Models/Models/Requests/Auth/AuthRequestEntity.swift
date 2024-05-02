//
//  AuthRequestEntity.swift
//
//  Created by Andrei Frolov on 11.04.24.
//

import NodeKit

public struct AuthRequestEntity {
    
    // MARK: - Properties
    
    public let email: String
    public let password: String
    
    // MARK: - Initialization
    
    public init(email: String, password: String) {
        self.email = email
        self.password = password
    }
}

extension AuthRequestEntity: DTOEncodable {
    public typealias DTO = AuthRequestEntry
    
    public func toDTO() throws -> AuthRequestEntry {
        return AuthRequestEntry(email: email, password: password)
    }
}
