//
//  Throttler.swift
//  NodeKit
//
//  Created by Никита Коробейников on 16.12.2020.
//  Copyright © 2020 Кравченков Александр. All rights reserved.
//

import Foundation

class Throttler {

    private static var dictionary: [String: Throttler] = [:]

    static func get(by key: String) -> Throttler {
        if let throttler = dictionary[key] {
            return throttler
        } else {
            let throttler = Throttler()
            dictionary[key] = throttler
            return throttler
        }
    }

    private var lastExecutedAt: Date?

    private init() {}

    func run(delay: DispatchTimeInterval, action: @escaping () -> Void) {
        let now = Date()
        let seconds = now.timeIntervalSince(lastExecutedAt ?? .distantPast)

        if seconds > delay.seconds {
            lastExecutedAt = now
            action()
        }
    }
}

fileprivate extension DispatchTimeInterval {

    var seconds: TimeInterval {
        switch self {
        case .seconds(let seconds):
            return TimeInterval(seconds)
        case .milliseconds(let milliseconds):
            return TimeInterval(milliseconds) / 1000
        case .microseconds(let microseconds):
            return TimeInterval(microseconds) / 1000000
        case .nanoseconds(let nanoseconds):
            return TimeInterval(nanoseconds) / 1000000000
        default:
            return 0
        }
    }

}
