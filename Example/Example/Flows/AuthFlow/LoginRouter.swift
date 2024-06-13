//
//  LoginRouter.swift
//  Example
//
//  Created by Andrei Frolov on 15.04.24.
//  Copyright © 2024 Кравченков Александр. All rights reserved.
//

import UIKit

protocol LoginRouterInput: ErrorRepresentable {
    
    @MainActor
    func showFeatureList()
}

struct LoginRouter {
    
    // MARK: - Properties
    
    private let viewController: UIViewController
    
    // MARK: - Initialization
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
}

// MARK: - LoginRouterInput

extension LoginRouter: LoginRouterInput {
    
    @MainActor
    func showFeatureList() {
        let featureListViewController = FeatureListConfigurator().configure()
        viewController.navigationController?.viewControllers = [featureListViewController]
    }
}
