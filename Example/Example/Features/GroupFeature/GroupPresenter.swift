//
//  GroupPresenter.swift
//  Example
//
//  Created by Andrei Frolov on 15.04.24.
//  Copyright © 2024 Кравченков Александр. All rights reserved.
//

import Models
import NodeKit
import Services

protocol GroupViewOutput {
    
    @MainActor
    func viewDidLoad()
}

final class GroupPresenter {
    
    // MARK: - Private Properties
    
    private weak var input: GroupViewInput?
    private let viewModelProvider: GroupViewModelProviderProtocol
    
    // MARK: - Initialization
    
    init(input: GroupViewInput, viewModelProvider: GroupViewModelProviderProtocol) {
        self.input = input
        self.viewModelProvider = viewModelProvider
    }
}

// MARK: - GroupViewOutput

extension GroupPresenter: GroupViewOutput {
    
    @MainActor
    func viewDidLoad() {
        input?.showLoader()
        start()
    }
}

// MARK: - Private Methods

private extension GroupPresenter {
    
    func start() {
        Task {
            do {
                let viewModel = try await viewModelProvider.provide()
                await input?.hideLoader()
                await input?.update(with: viewModel)
            } catch {
                if !(error is CancellationError) {
                    await input?.show(error: error)
                }
            }
        }
    }
}
