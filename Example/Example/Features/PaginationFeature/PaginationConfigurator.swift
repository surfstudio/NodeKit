//
//  PaginationConfigurator.swift
//  Example
//
//  Created by Andrei Frolov on 15.04.24.
//  Copyright © 2024 Кравченков Александр. All rights reserved.
//

import NodeKit
import Services
import UIKit

struct PaginationConfigurator {
    
    // MARK: - Constants
    
    private enum Constants {
        static let pageSize: Int = 15
    }
    
    // MARK: - Methods
    
    func configure() -> UIViewController {
        guard
            let viewController = UIStoryboard.instantiate(ofType: PaginationViewController.self)
        else {
            fatalError("Can't load PaginationViewController from storyboard")
        }
        
        let router = PaginationRouter()
        let presenter = PaginationPresenter(
            input: viewController,
            router: router,
            iterator: AsyncPagerIterator(
                dataProvider: PaginationContentDataProvider(),
                pageSize: Constants.pageSize
            )
        )
        
        viewController.output = presenter
        
        return viewController
    }
}
