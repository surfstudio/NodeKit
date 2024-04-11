//
//  LoggingContext.swift
//  NodeKit
//
//  Created by frolov on 19.03.2024.
//  Copyright © 2024 Surf. All rights reserved.
//

import Foundation

protocol LoggingContextProtocol: Actor {
    // Лог контекста
    var log: Logable? { get }

    /// Добавляет лог-сообщение к контексту.
    /// - Parameter log: лог-сообщение.
    func add(_ log: Logable?)
}

actor LoggingContext: LoggingContextProtocol {

    // Лог контекста
    public private(set) var log: Logable?

    /// Добавляет лог-сообщение к контексту.
    /// В случае, если у контекста не было лога, то он появится.
    /// В случае, если у контекста был лог, но у него не было следующего, то этот добавится в качестве следующего лога.
    /// В случае, если лог был, а у него был следующий лог, то этот будет вставлен между ними.
    ///
    /// - Parameter log: лог-сообщение.
    public func add(_ log: Logable?) {
        guard var currentLog = self.log else {
            self.log = log
            return
        }

        if currentLog.next == nil {
            currentLog.next = log
        } else {
            var temp = log
            temp?.next = currentLog.next
            currentLog.next = temp
        }

        self.log = currentLog
        return
    }

}
