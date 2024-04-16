//
//  GroupConfigurator.swift
//  Example
//
//  Created by Andrei Frolov on 15.04.24.
//  Copyright © 2024 Кравченков Александр. All rights reserved.
//

import Services
import UIKit

struct GroupConfigurator {
    
    // MARK: - Methods
    
    func configure() -> UIViewController {
        guard
            let viewController = UIStoryboard.instantiate(ofType: GroupViewController.self)
        else {
            fatalError("Can't load FeatureListViewController from storyboard")
        }
        
        let presenter = GroupPresenter(
            input: viewController,
            viewModelProvider: GroupViewModelProvider(groupService: GroupService())
        )
        
        viewController.output = presenter
        return viewController
    }
}
