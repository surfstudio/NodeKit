//
//  FeatureListConfigurator.swift
//  Example
//
//  Created by Andrei Frolov on 15.04.24.
//  Copyright © 2024 Кравченков Александр. All rights reserved.
//

import UIKit

struct FeatureListConfigurator {
    
    // MARK: - Methods
    
    func configure() -> UIViewController {
        guard
            let viewController = UIStoryboard.instantiate(ofType: FeatureListViewController.self)
        else {
            fatalError("Can't load FeatureListViewController from storyboard")
        }
        
        let router = FeatureListRouter(viewController: viewController)
        let presenter = FeatureListPresenter(input: viewController, router: router)
        
        viewController.output = presenter
        
        return viewController
    }
}
