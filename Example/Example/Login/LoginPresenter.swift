//
//  LoginPresenter.swift
//  Example
//
//  Created by Александр Кравченков on 09.12.2017.
//  Copyright © 2017 Кравченков Александр. All rights reserved.
//

import Foundation

public struct LoginViewModel {
    let email: String
    let password: String
}

public class LoginPresenter {

    var view: LoginViewController?

    public func login(email: String?, password: String?) {
        guard let guardedEmail = email, let guardedPassword = password else {
            return
        }

        AuthService().auth(by: guardedEmail, and: guardedPassword)
            .onCompleted { [weak self] in
                self?.view?.authComplete()
            }
            .onError { [weak self] (error) in
                self?.view?.showError(error)
            }
    }
}
