//
//  AsyncPagerDataProvider.swift
//  NodeKit
//
//  Created by Andrei Frolov on 15.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import Foundation

/// Result of the request ``AsyncPagerDataProvider``.
public struct AsyncPagerData<Value> {
    public let value: Value
    public let len: Int
    
    public init(value: Value, len: Int) {
        self.value = value
        self.len = len
    }
}

/// Protocol describing a data provider that returns the result of the chain or node operation.
public protocol AsyncPagerDataProvider<Value> {
    associatedtype Value
    
    /// Data request method.
    ///
    /// - Parameters:
    ///   - index: The index from which data will be requested.
    ///   - pageSize: Number of items per page.
    /// - Returns: Result of the chain or node operation.
    func provide(for index: Int, with pageSize: Int) async -> NodeResult<AsyncPagerData<Value>>
}
