//
//  URLSessionDataTaskActor.swift
//  NodeKit
//
//  Created by Andrei Frolov on 08.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import Foundation

public protocol URLSessionDataTaskActorProtocol: Actor {
    func store(task: CancellableTask)
    func cancelTask()
}

public actor URLSessionDataTaskActor: URLSessionDataTaskActorProtocol {
    
    // MARK: - Private Properties
    
    private var task: CancellableTask?
    
    // MARK: - URLSessionTaskActorProtocol
    
    public func store(task: CancellableTask) {
        self.task = task
    }
    
    public func cancelTask() {
        task?.cancel()
        task = nil
    }
}
