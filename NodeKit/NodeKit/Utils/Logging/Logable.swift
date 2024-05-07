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

    /// Порядок лога в цепочке. Необходим для сортировки.
    var order: Double { get }

    /// Следующая лог-запись.
    var next: Logable? { get set }

    //// Идентификатор лог-сообщения.
    var id: String { get }

    /// Выводит всю цепоку логов с заданным форматированием.
    var description: String { get }

    /// Добавляет сообщение к логу.
    ///
    /// - Parameter message: Лог-сообщение.
    mutating func add(message: String)
}

extension Logable {
    /// Преобразет древовидную структуру записи логов в массив
    /// посредством нерекурсивного обхода вглубину
    func flatMap() -> [Logable] {
        var currentLogable: Logable? = self
        var result = [Logable]()
        while currentLogable != nil {
            guard var log = currentLogable else { break }
            currentLogable = log.next
            log.next = nil
            result.append(log)
        }
        return result
    }
}
