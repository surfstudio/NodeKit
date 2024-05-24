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
        
        /// Создаем таски, которые при ошибке останавливают все сохраненные таски.
        
        let headerTask = storedTask { await $0.header() }
        let bodyTask = storedTask { await $0.body() }
        let footerTask = storedTask { await $0.footer() }
        
        /// Ждем результаты.
        /// Так как CancellationError не в приоритете, игнорируем ее на этом этапе.
        /// По всем остальным ошибка словим Exception.

        let header = try await resultWithCheckedError(from: headerTask)
        let body = try await resultWithCheckedError(from: bodyTask)
        let footer = try await resultWithCheckedError(from: footerTask)
        
        /// Собираем модель.
        /// На этом этапе мы можем словить Exception только c CancellationError.
        /// Необходимо обработать ее на уровне выше.
        /// Кейс когда словили CancellationError - все остановленные таски отработали без ошибок.
    
        return try GroupViewModel(
            headerTitle: header.get().text,
            headerImage: header.get().image,
            bodyTitle: body.get().text,
            bodyImage: body.get().image,
            footerTitle: footer.get().text,
            footerImage: footer.get().image
        )
    }
}

// MARK: - Private Methods

private extension GroupViewModelProvider {
    
    func storedTask<T>(_ nodeResult: @escaping (GroupServiceProtocol) async -> NodeResult<T>) -> Task<NodeResult<T>, Never> {
        let task = Task {
            await nodeResult(groupService)
                .mapError {
                    cancelAllTasks()
                    return $0
                }
        }
        tasks.append(task)
        return task
    }
    
    func resultWithCheckedError<T>(from task: Task<NodeResult<T>, Never>) async throws -> NodeResult<T> {
        let value = await task.value
        
        if let error = value.error, !(error is CancellationError) {
            throw error
        }
        
        return value
    }
    
    func cancelAllTasks() {
        tasks.forEach { $0.cancel() }
        tasks.removeAll()
    }
}
