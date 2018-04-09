//
//  LoginService.swift
//  Example
//
//  Created by Александр Кравченков on 09.12.2017.
//  Copyright © 2017 Кравченков Александр. All rights reserved.
//

import Foundation
import CoreNetKit

class AuthService {

    func auth(by email: String, and passwod: String) -> ActionableContext<Void> {
        let result = PassiveRequestContext<Void>()
        self.getAuthToken(by: email, and: passwod)
            .onCompleted { (entity) in
                // TODO: write to store
                result.performComplete(result: ())
            }.onError { (error) in
                result.performError(error: error)
            }
        return result
    }

    private func getAuthToken(by email: String, and passwod: String) -> ActionableContext<AuthTokenEntity> {
        let request = AuthRequest(email: email, password: passwod)
        return ActiveRequestContext(request: request).perform()
    }
}
