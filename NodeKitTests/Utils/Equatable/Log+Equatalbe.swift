//
//  Log+Equatalbe.swift
//  NodeKitTests
//
//  Created by frolov on 19.03.2024.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit

extension Log: Equatable {
    
    public static func == (lhs: NodeKit.Log, rhs: NodeKit.Log) -> Bool {
        return lhs.message == rhs.message &&
            lhs.description == rhs.description &&
            lhs.delimeter == rhs.delimeter &&
            lhs.id == rhs.id &&
            lhs.order == rhs.order
    }
    
}
