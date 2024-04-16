//
//  AsyncPagerDataProvider.swift
//  NodeKit
//
//  Created by Andrei Frolov on 15.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import Foundation

/// Результат запроса ``AsyncPagerDataProvider``.
public struct AsyncPagerData<Value> {
    public let value: Value
    public let len: Int
    
    public init(value: Value, len: Int) {
        self.value = value
        self.len = len
    }
}

/// Протокол описывающий провайдера данных, который возвращает результат работы цепочки или узла.
public protocol AsyncPagerDataProvider<Value> {
    associatedtype Value
    
    /// Метод запроса данных.
    ///
    /// - Parameters:
    ///  - index: Индекс с которого будут запрошены данные.
    ///  - pageSize: Количество элементов на странице.
    /// - Returns: Результат работыу цепочки или узла.
    func provide(for index: Int, with pageSize: Int) async -> NodeResult<AsyncPagerData<Value>>
}
