//
//  LogWrapper.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 07/04/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// Описывает сущность, которая содержит описание для лога работы.
protocol Logable {
    var description: String { get }
}

/// Структура, описывающая лог работы.
struct Log: Logable {

    /// Разделитель, который будет вставлен между логами.
    /// По-умолчанию равен `\n`
    var delimeter: String

    /// Следующий лог.
    var next: Logable?

    /// Содержание данного лога.
    var message: String

    /// Инициаллизирует объект.
    ///
    /// - Parameters:
    ///   - message: Содержание данного лога.
    ///   - delimeter: Разделитель, который будет вставлен между логами. По-умолчанию равен `\n`
    init(_ message: String, delimeter: String = "\n") {
        self.message = message
        self.delimeter = delimeter
    }

    /// Прибавлеяет `delimeter`к собственному `message`, затем к полученной строке прибавляет `next.description`.
    var description: String {
        let result = message + self.delimeter

        return result + (self.next?.description ?? "")
    }
}

extension Log {
    /// Пустое лог-сообщение (без текста)
    static var defaultEmpty: Logable {
        return Log("")
    }
}

/// Обертка, которая к обычным данным типа `T` добавляет лог-сообщение `Logable`
struct LogWrapper<T> {
    /// Целевые данные.
    var data: T
    /// Лог-сообщение.
    /// По-умолчанию `Log.defaultEmpty`
    var log: Logable

    /// Инициаллизирует объект.
    ///
    /// - Parameters:
    ///   - data: Целевые данные.
    ///   - log: Лог-сообщение. По-умолчанию `Log.defaultEmpty`
    init(data: T, log: Logable = Log.defaultEmpty) {
        self.data = data
        self.log = log
    }
}

extension Node {
    /// Возвращает имя типа строкой
    var objectName: String {
        return "\(type(of: self))"
    }
}
