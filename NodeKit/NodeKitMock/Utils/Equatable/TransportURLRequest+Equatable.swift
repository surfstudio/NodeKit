//
//  TransportURLRequest+Equatable.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 04.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit

extension TransportURLRequest: Equatable {
    public static func == (lhs: TransportURLRequest, rhs: TransportURLRequest) -> Bool {
        return lhs.headers == rhs.headers &&
            lhs.url == rhs.url &&
            lhs.method == rhs.method &&
            lhs.raw == rhs.raw
    }
}
