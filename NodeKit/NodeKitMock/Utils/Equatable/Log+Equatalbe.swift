//
//  Log+Equatalbe.swift
//  NodeKitTests
//
//  Created by frolov on 19.03.2024.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit

extension LogChain: Equatable {

    public static func == (lhs: LogChain, rhs: LogChain) -> Bool {
        return lhs.message == rhs.message &&
            lhs.description == rhs.description &&
            lhs.delimeter == rhs.delimeter &&
            lhs.logType == rhs.logType &&
            lhs.id == rhs.id &&
            lhs.order == rhs.order
    }

}
