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
            makePaginationViewModel(),
            makeGroupOfRequestsViewModel()
        ].map {
            FeatureCell.rddm.baseGenerator(with: $00)
        }
    }
    
    func makePaginationViewModel() -> FeatureCellViewModel {
        let viewModel = FeatureCellViewModel("Pagination")
        viewModel.didTap = { [weak self] in self?.router.showPagination() }
        return viewModel
    }
    
    func makeGroupOfRequestsViewModel() -> FeatureCellViewModel {
        let viewModel = FeatureCellViewModel("Group of requests")
        viewModel.didTap = { [weak self] in self?.router.showGroup() }
        return viewModel
    }
}
