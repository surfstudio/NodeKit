//
//  TokenRefresherActor.swift
//  NodeKit
//
//  Created by frolov on 20.03.2024.
//  Copyright © 2024 Surf. All rights reserved.
//

actor TokenRefresherActor {
    private var tokenRefreshChain: any Node<Void, Void>
    private(set) var task: Task<Result<Void, Error>, Never>?

    init(tokenRefreshChain: some Node<Void, Void>) {
        self.tokenRefreshChain = tokenRefreshChain
    }

    func refresh(logContext: LoggingContextProtocol) async -> Result<Void, Error> {
        let refreshTask = Task {
            return await tokenRefreshChain.process((), logContext: logContext)
        }
        task = refreshTask
        let value = await refreshTask.value
        task = nil
        return value
    }
}
