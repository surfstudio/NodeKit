//
//  FeatureListPresenter.swift
//  Example
//
//  Created by Andrei Frolov on 15.04.24.
//  Copyright © 2024 Кравченков Александр. All rights reserved.
//

import ReactiveDataDisplayManager

protocol FeatureListViewOutput {
    
    func viewDidLoad()
}

final class FeatureListPresenter {
    
    // MARK: - Private Properties
    
    private weak var input: FeatureListViewInput?
    private let router: FeatureListRouterInput
    
    // MARK: - Initialization
    
    init(input: FeatureListViewInput, router: FeatureListRouterInput) {
        self.input = input
        self.router = router
    }
}

// MARK: - FeatureListViewOutput

extension FeatureListPresenter: FeatureListViewOutput {
    
    func viewDidLoad() {
        input?.update(with: makeGenerators())
    }
}


// MARK: - Private Methods

private extension FeatureListPresenter {
    
    func makeGenerators() -> [TableCellGenerator] {
        return [
            makePaginationGenerator(),
            makeRequestsChainGenerator()
        ]
    }
    
    func makePaginationGenerator() -> TableCellGenerator {
        let generator = FeatureCellGenerator("Pagination")
        
        generator.didTap = { [weak self] in
            self?.router.showPagination()
        }
        
        return generator
    }
    
    func makeRequestsChainGenerator() -> TableCellGenerator {
        let generator = FeatureCellGenerator("Group of requests")
        
        generator.didTap = { [weak self] in
            self?.router.showGroup()
        }
        
        return generator
    }
}
