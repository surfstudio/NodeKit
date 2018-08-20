//
//  Atomic.swift
//  CoreNetKit
//
//  Created by Alexander Kravchenkov on 20.08.2018.
//  Copyright © 2018 Кравченков Александр. All rights reserved.
//

import Foundation

public struct Atomic<Value> {

    private let locker: NSLock
    private var value: Value

    init(value: Value) {
        self.value = value
        self.locker = NSLock()
    }

    mutating func write(value: Value) {
        self.locker.lock()
        self.value = value
        self.locker.unlock()
    }

    func read() -> Value {
        defer {
            self.locker.unlock()
        }
        self.locker.lock()
        return self.value
    }
}
