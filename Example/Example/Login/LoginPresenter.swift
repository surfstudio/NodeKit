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

    private var model: LoginViewModel?

    public func updateModel(model: LoginViewModel) {
        self.model = model
    }

    public func login() {
        guard let guardModel = self.model else {
            return
        }

        LoginService().login(email: guardModel.email, password: guardModel.password).
//        LoginService().login(email: guardModel.email, password: guardModel.password)
//            .onCompleted {
//                // completed
//            }
//            .onError {
//            }
    }
}
