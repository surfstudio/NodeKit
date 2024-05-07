//
//  GroupViewModelProvider.swift
//  Example
//
//  Created by Andrei Frolov on 16.04.24.
//  Copyright © 2024 Кравченков Александр. All rights reserved.
//

import Foundation
import Models
import NodeKit
import Services

protocol GroupViewModelProviderProtocol: Actor {
    func provide() async throws -> GroupViewModel
}

actor GroupViewModelProvider: GroupViewModelProviderProtocol {
    
    // MARK: - Private Properties
    
    private var tasks: [CancellableTask] = []
    private let groupService: GroupServiceProtocol
    
    // MARK: - Initialization
    
    init(groupService: GroupServiceProtocol) {
        self.groupService = groupService
    }
    
    // MARK: - GroupViewModelServiceProtocol
    
    func provide() async throws -> GroupViewModel {
        cancelAllTasks()
        
        let headerTask = storedTask { await $0.header() }
        let bodyTask = storedTask { await $0.body() }
        let footerTask = storedTask { await $0.footer() }
        
        async let header = headerTask.value
        async let body = bodyTask.value
        async let footer = footerTask.value
        
        return try await GroupViewModel(
            headerTitle: header.text,
            headerImage: header.image,
            bodyTitle: body.text,
            bodyImage: body.image,
            footerTitle: footer.text,
            footerImage: footer.image
        )
    }
}

// MARK: - Private Methods

private extension GroupViewModelProvider {
    
    func storedTask<T>(_ nodeResult: @escaping (GroupServiceProtocol) async -> NodeResult<T>) -> Task<T, Error> {
        let task = Task {
            try await nodeResult(groupService)
                .mapError {
                    cancelAllTasks()
                    return $0
                }
                .get()
        }
        tasks.append(task)
        return task
    }
    
    func cancelAllTasks() {
        tasks.forEach { $0.cancel() }
        tasks.removeAll()
    }
}
