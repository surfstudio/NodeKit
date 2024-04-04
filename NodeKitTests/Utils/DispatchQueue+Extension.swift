//
//  DispatchQueue+Extension.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 04.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import Foundation

extension DispatchQueue {
    static var currentLabel: String {
        return String(validatingUTF8: __dispatch_queue_get_label(nil)) ?? ""
    }
}
