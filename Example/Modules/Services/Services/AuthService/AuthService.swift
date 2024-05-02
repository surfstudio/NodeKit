//
//  LoginService.swift
//
//  Created by Andrei Frolov on 15.04.24.
//

import Foundation
import Models
import NodeKit
import NodeKitMock

public protocol AuthServiceProtocol {
    func auth(by email: String, and passwod: String) async -> NodeResult<Void>
}

public struct AuthService: AuthServiceProtocol {
    
    public init() { }
    
    public func auth(by email: String, and passwod: String) async -> NodeResult<Void> {
        return await UrlChainsBuilder<AuthURLProvider>()
            .set(session: NetworkMock().urlSession)
            .encode(as: .urlQuery)
            .route(.post, .login)
            .build()
            .process(AuthRequestEntity(email: email, password: passwod))
    }
}
