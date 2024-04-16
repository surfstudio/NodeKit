//
//  AsyncIterator.swift
//  NodeKit

/// Интерфейс любого асинхронно интерируемого компонента
///
/// pageSize, offset и другие параметры указываются в конкретной реализации протокола
public protocol AsyncIterator<Value>: Actor {
    associatedtype Value
    
    /// Запрос следующих данных
    func next() async -> Result<Value, Error>
    
    /// Показывает есть ли еще данные
    func hasNext() -> Bool

    /// Сброс свойств итератора
    func renew()
}
