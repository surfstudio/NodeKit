//
//  Debouncer.swift
//  NodeKit
//
//  Created by Никита Коробейников on 16.12.2020.
//  Copyright © 2020 Кравченков Александр. All rights reserved.
//

import Foundation

class Debouncer {

    private var workItem: DispatchWorkItem?

    func run(on queue: DispatchQueue, delay: DispatchTimeInterval, action: @escaping () -> Void) {
        workItem?.cancel()
        let workItem = DispatchWorkItem(block: action)
        queue.asyncAfter(deadline: .now() + delay, execute: workItem)

        self.workItem = workItem
    }
}
