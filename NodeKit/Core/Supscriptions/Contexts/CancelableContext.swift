//
//  CancelableContext.swift
//  NodeKit
//
//  Created by Vladislav Krupenko on 26.01.2020.
//  Copyright © 2020 Кравченков Александр. All rights reserved.
//

import Foundation

/// Протокол, который обладает базовой реализацией над Observer.
/// Кейс использования – отмена реквестов в цикле
public protocol CancelableContext {
    @discardableResult
    func cancel() -> Self
}

extension Observer: CancelableContext {}
