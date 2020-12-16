//
//  Debouncer.swift
//  NodeKit
//
//  Created by Никита Коробейников on 16.12.2020.
//  Copyright © 2020 Кравченков Александр. All rights reserved.
//

import Foundation

class Debouncer {

    private static var dictionary: [String: Debouncer] = [:]

    static func get(by key: String) -> Debouncer {
        if let debouncer = dictionary[key] {
            return debouncer
        } else {
            let debouncer = Debouncer()
            dictionary[key] = debouncer
            return debouncer
        }
    }

    private var workItem: DispatchWorkItem?

    private init() {}

    func run(on queue: DispatchQueue, delay: DispatchTimeInterval, action: @escaping () -> Void) {
        workItem?.cancel()
        let workItem = DispatchWorkItem(block: action)
        queue.asyncAfter(deadline: .now() + delay, execute: workItem)

        self.workItem = workItem
    }
}
