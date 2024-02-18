//
//  TokenRefresherActor.swift
//  NodeKit
//
//  Created by frolov on 15.02.2024.
//  Copyright © 2024 Surf. All rights reserved.
//

@available(iOS 13.0, *)
actor TokenRefresherActor {
    private var tokenRefreshChain: Node<Void, Void>
    private(set) var task: Task<Result<Void, Error>, Never>?

    init(tokenRefreshChain: Node<Void, Void>) {
        self.tokenRefreshChain = tokenRefreshChain
    }

    func refresh() async -> Result<Void, Error> {
        let refreshTask = Task {
            return await tokenRefreshChain.process(())
        }
        task = refreshTask
        let value = await refreshTask.value
        task = nil
        return value
    }
}
