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

/// Описывает тип логируемого сообщения в смысле направления работы узла
///
/// - input: В случае, когда узел получил управления после вызова `process`
/// - output: В случае, когда узел получил управление в результате окончания работы последующих узлов (по подписке)
enum LogType {
    case input
    case output
}

/// Структура, описывающая лог работы.
struct Log: Logable {

    /// Идентификатор лога.
    struct Id {
        /// Идентификатор узла. По-умолчанию содержит имя (`Node.objectName`) узла
        var id: String
        /// Тип лога.
        var type: LogType
    }

    /// Разделитель, который будет вставлен между логами.
    /// По-умолчанию равен `\n`
    var delimeter: String

    /// Следующий лог.
    var next: Logable?

    /// Содержание данного лога.
    var message: String

    /// Идентификатор лог-записи.
    let id: Id

    /// Инициаллизирует объект.
    ///
    /// - Parameters:
    ///   - message: Содержание данного лога.
    ///   - delimeter: Разделитель, который будет вставлен между логами. По-умолчанию равен `\n`
    init(_ message: String, id: Id, delimeter: String = "\n") {
        self.message = message
        self.delimeter = delimeter
        self.id = id
    }

    /// Прибавлеяет `delimeter`к собственному `message`, затем к полученной строке прибавляет `next.description`.
    var description: String {
        let result = message + self.delimeter

        return result + (self.next?.description ?? "")
    }
}

/// Обертка, которая к обычным данным типа `T` добавляет лог-сообщение `Logable`
struct LogWrapper<T> {
    /// Целевые данные.
    var data: T
    /// Лог-сообщение.
    /// По-умолчанию `Log.defaultEmpty`
    var log: Logable
}

extension Node {
    /// Возвращает имя типа строкой
    var objectName: String {
        return "\(type(of: self))"
    }
}
