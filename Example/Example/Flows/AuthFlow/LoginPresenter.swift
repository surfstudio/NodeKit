//
//  LoginPresenter.swift
//  Example
//
//  Created by Александр Кравченков on 09.12.2017.
//  Copyright © 2017 Кравченков Александр. All rights reserved.
//

import Foundation
import Services

protocol LoginViewOutput {
    func credentialsDidReceive(credentials: Credentials?)
}

public class LoginPresenter {
    
    // MARK: - Private Properties
    
    private let router: LoginRouterInput
    private let service: AuthServiceProtocol
    
    // MARK: - Initialization
    
    init(router: LoginRouterInput, service: AuthServiceProtocol) {
        self.router = router
        self.service = service
    }
}

// MARK: - LoginViewOutput

extension LoginPresenter: LoginViewOutput {
    
    func credentialsDidReceive(credentials: Credentials?) {
        guard let credentials else {
            return
        }
        
        Task { await auth(with: credentials) }
    }
}

// MARK: - Private Methods

private extension LoginPresenter {
    
    private func auth(with credentials: Credentials) async {
        let result = await service.auth(by: credentials.email, and: credentials.password)
        switch result {
        case .success:
            await router.showFeatureList()
        case .failure(let error):
            await router.show(error: error)
        }
    }
}
