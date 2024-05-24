//
//  Node.swift
//  CoreNetKitWithExample
//
//  Created by Александр Кравченков on 27/11/2018.
//  Copyright © 2018 Александр Кравченков. All rights reserved.
//

import Foundation

/// Протокол, описывающий любой узел или цепочку узлов.
/// Необходим для объединения всех типов узлов и добавления общих методов.
public protocol Node { }

/// Содержит вычисляемые константы
public extension Node {
    /// Возвращает имя типа строкой
    var objectName: String {
        return "\(type(of: self))"
    }

    /// Имея объекта в формате:
    /// <<<===\(self.objectName)===>>>" + `String.lineTabDeilimeter`
    var logViewObjectName: String {
        return "<<<===\(self.objectName)===>>>" + .lineTabDeilimeter
    }
}
