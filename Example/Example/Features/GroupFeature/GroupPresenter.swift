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

final class GroupPresenter: ErrorRepresentable {
    
    // MARK: - Nested Types
    
    private enum GroupTaskResult {
        case header(GroupHeaderResponseEntity)
        case body(GroupBodyResponseEntity)
        case footer(GroupFooterResponseEntity)
    }
    
    // MARK: - Private Properties
    
    private weak var input: GroupViewInput?
    private let service: GroupViewModelServiceProtocol
    
    private var cancellables: [CancellableTask] = []
    
    // MARK: - Initialization
    
    init(input: GroupViewInput, service: GroupViewModelServiceProtocol) {
        self.input = input
        self.service = service
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
                let result = try await service.viewModel()
                await input?.hideLoader()
                await input?.update(with: result)
            } catch {
                await show(error: error)
            }
        }
    }
}
