//
//  LoginConfigurator.swift
//  Example
//
//  Created by Andrei Frolov on 15.04.24.
//  Copyright © 2024 Кравченков Александр. All rights reserved.
//

import Services
import UIKit

struct LoginConfigurator {
    
    // MARK: - Methods
    
    func configure() -> UIViewController {
        guard
            let viewController = UIStoryboard.instantiate(ofType: LoginViewController.self)
        else {
            fatalError("Can't load LoginViewController from storyboard")
        }
        
        let router = LoginRouter(viewController: viewController)
        let presenter = LoginPresenter(router: router, service: AuthService())
        
        viewController.output = presenter
        
        return UINavigationController(rootViewController: viewController)
    }
}
