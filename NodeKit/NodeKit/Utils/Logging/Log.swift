//
//  Log.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 07/04/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// Структура, описывающая лог работы.
public struct Log: Logable {

    /// Порядок лога в цепочке. Необходим для сортировки.
    public var order: Double = 0

    /// Разделитель, который будет вставлен между логами.
    /// По-умолчанию равен `\n`
    public var delimeter: String

    /// Следующий лог.
    public var next: Logable?

    /// Содержание данного лога.
    public var message: String

    /// Идентификатор узла. По-умолчанию содержит имя (`Node.objectName`) узла
    public var id: String

    /// Инициаллизирует объект.
    ///
    /// - Parameters:
    ///   - message: Содержание данного лога.
    ///   - delimeter: Разделитель, который будет вставлен между логами. По-умолчанию равен `\n`
    public init(_ message: String, id: String, delimeter: String = "\n", order: Double = 0) {
        self.message = message
        self.delimeter = delimeter
        self.id = id
        self.order = order
    }

    /// Прибавлеяет `delimeter`к собственному `message`, затем к полученной строке прибавляет `next.description`.
    public var description: String {
        let result = self.delimeter + message + self.delimeter

        return result + (self.next?.description ?? "")
    }

    /// Добавляет сообщение к логу.
    ///
    /// - Parameter message: Лог-сообщение.
    mutating public func add(message: String) {
        self.message += message
    }

    /// Синтаксический сахар для `add(message:)`
    public static func += (lhs: inout Log, rhs: String) {
        lhs.add(message: rhs)
    }
}
