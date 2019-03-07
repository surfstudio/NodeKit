//
//  TokenRefresherNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 06/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

open class TokenRefresherNode: Node<Void, Void> {

    var tokenRefreshChain: Node<Void, Void>

    var isRequestSended = false
    var observers: [Context<Void>]

    private let arrayQueue = DispatchQueue(label: "TokenRefresherNode.observers")
    private let flagQueue = DispatchQueue(label: "TokenRefresherNode.flag")

    public init(tokenRefreshChain: Node<Void, Void>) {
        self.tokenRefreshChain = tokenRefreshChain
        self.observers = []
    }

    open override func process(_ data: Void) -> Observer<Void> {


        let shouldSaveContext: Bool = self.flagQueue.sync {
            if self.isRequestSended {
                return true
            } else {
                self.isRequestSended = true
            }
            return false
        }

        if shouldSaveContext {
            return self.arrayQueue.sync {
                let result = Context<Void>()
                self.observers.append(result)
                return result
            }
        }

        return self.tokenRefreshChain.process(()).map {
            self.observers.forEach { $0.emit(data: ()) }
            return ()
        }
    }
}
