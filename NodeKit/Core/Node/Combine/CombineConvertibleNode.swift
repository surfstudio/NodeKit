//
//  CombineConvertibleNode.swift
//  NodeKit
//
//  Created by Andrei Frolov on 29.03.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import Foundation

/// Протокол наследованный от Node, добавляющий возможность конвертации ноды в ``CombineNode``.
public protocol CombineConvertibleNode: Node {
    
    /// Преобразование ноды в ``CombineNode`` для поддержки работы с Combine.
    ///
    /// - Returns: Нода с поддержкой работы Combine.
    func combineNode() -> any CombineNode<Input, Output>
}
