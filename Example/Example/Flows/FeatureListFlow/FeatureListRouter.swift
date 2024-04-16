//
//  FeatureListRouter.swift
//  Example
//
//  Created by Andrei Frolov on 15.04.24.
//  Copyright © 2024 Кравченков Александр. All rights reserved.
//

import UIKit

protocol FeatureListRouterInput {
    
    @MainActor
    func showPagination()
    
    @MainActor
    func showGroup()
}

struct FeatureListRouter {
    
    // MARK: - Private Properties
    
    private weak var viewController: UIViewController?
    
    // MARK: - Initialization
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
}

// MARK: - FeatureListRouterInput

extension FeatureListRouter: FeatureListRouterInput {
    
    @MainActor
    func showPagination() {
        let paginationViewController = PaginationConfigurator().configure()
        paginationViewController.navigationItem.largeTitleDisplayMode = .never
        viewController?.navigationController?.pushViewController(paginationViewController, animated: true)
    }
    
    @MainActor
    func showGroup() {
        let groupViewController = GroupConfigurator().configure()
        groupViewController.navigationItem.largeTitleDisplayMode = .never
        viewController?.navigationController?.pushViewController(groupViewController, animated: true)
    }
}
