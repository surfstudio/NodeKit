//
//  AuthRequest.swift
//  Example
//
//  Created by Alexander Kravchenkov on 04.04.2018.
//  Copyright © 2018 Кравченков Александр. All rights reserved.
//

import Foundation
import CoreNetKit

enum AuthErrors: LocalizedError {
    case badCredentials(String)

    public var errorDescription: String? {
        switch self {
        case .badCredentials(let mesasge):
            return mesasge
        }
    }

}

class AuthErrorMapper: ErrorMapperAdapter {
    func map(json: [String : Any], httpCode: Int?) -> LocalizedError? {
        guard httpCode == 403, let message = json["Message"] as? String else {
            return nil
        }

        return AuthErrors.badCredentials(message)
    }
}

class AuthRequest: BaseServerRequest<AuthTokenEntity> {

    // MARK: - Nested

    private struct Keys {
        static let email = "email"
        static let password = "password"

        static let accessToken = "access-token"
        static let refreshToken = "refresh-token"
    }

    // MARK: - Private fields

    private let email: String
    private let password: String

    // MARK: - Initializers

    init(email: String, password: String) {
        self.email = email
        self.password = password
    }

    override func createAsyncServerRequest() -> CoreServerRequest {
        let params = [Keys.email: self.email, Keys.password: self.password]
        return BaseCoreServerRequest(method: .post, baseUrl: Urls.base, relativeUrl: Urls.Auth.url,
                                     parameters: .simpleParams(params), errorMapper: AuthErrorMapper(), cacheAdapter: nil)
    }

    override func handle(serverResponse: CoreServerResponse, completion: (ResponseResult<AuthTokenEntity>) -> Void) {
        switch serverResponse.result {
        case .success(let value as [String: String], let flag) where value[Keys.accessToken] != nil && value[Keys.refreshToken] != nil:
            let entity = AuthTokenEntity(accessToken: value[Keys.accessToken]!, refreshtoken: value[Keys.refreshToken]!)
            completion(.success(entity, flag))
        case .failure(let error):
            completion(.failure(error))
        default:
            completion(.failure(BaseServerError.cantMapping))
        }
    }
}
