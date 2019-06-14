//
//  LoggerExtensions.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 07/04/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// Содержит вычисляемые константы
public extension Node {
    /// Возвращает имя типа строкой
    var objectName: String {
        return "\(type(of: self))"
    }

    /// Имея обхекта в формате:
    /// <<<===\(self.objectName)===>>>" + `String.lineTabDeilimeter`
    var logViewObjectName: String {
        return "<<<===\(self.objectName)===>>>" + .lineTabDeilimeter
    }
}

/// Содержит вычисляемые константы
public extension String {
    /// Возвращает последовательность "\n\t"
    static var lineTabDeilimeter: String {
        return "\r\n"
    }
}
