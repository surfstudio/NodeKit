//
//  LogWrapper.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 07/04/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// Описывает сущность, которая содержит описание для лога работы.
public protocol Logable {
    /// Следующая лог-запись.
    var next: Logable? { get set }
    /// Выводит всю цепоку логов с заданным форматированием.
    var description: String { get }

    /// Добавляет сообщение к логу.
    ///
    /// - Parameter message: Лог-сообщение.
    mutating func add(message: String)
}

/// Структура, описывающая лог работы.
public struct Log: Logable {

    /// Разделитель, который будет вставлен между логами.
    /// По-умолчанию равен `\n`
    public var delimeter: String

    /// Следующий лог.
    public var next: Logable?

    /// Содержание данного лога.
    public var message: String

    //// Идентификатор узла. По-умолчанию содержит имя (`Node.objectName`) узла
    public var id: String

    /// Инициаллизирует объект.
    ///
    /// - Parameters:
    ///   - message: Содержание данного лога.
    ///   - delimeter: Разделитель, который будет вставлен между логами. По-умолчанию равен `\n`
    public init(_ message: String, id: String, delimeter: String = "\n") {
        self.message = message
        self.delimeter = delimeter
        self.id = id
    }

    /// Прибавлеяет `delimeter`к собственному `message`, затем к полученной строке прибавляет `next.description`.
    public var description: String {
        let result = self.delimeter + message + self.delimeter

        return result + (self.next?.description ?? "")
    }

    mutating public func add(message: String) {
        self.message += message
    }

    static func += (lhs: inout Log, rhs: String) {
        lhs.add(message: rhs)
    }
}

/// Обертка, которая к обычным данным типа `T` добавляет лог-сообщение `Logable`
public struct LogWrapper<T> {
    /// Целевые данные.
    public var data: T
    /// Лог-сообщение.
    /// По-умолчанию `Log.defaultEmpty`
    public var log: Logable
}

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

extension String {
    /// Возвращает последовательность "\n\t"
    static var lineTabDeilimeter: String {
        return "\r\n\t"
    }
}
