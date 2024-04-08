//
//  AsyncIterator.swift
//  NodeKit

/// Интерфейс любого асинхронно интерируемого компонента
///
/// pageSize, offset и другие параметры указываются в конкретной реализации протокола
public protocol AsyncIterator: Actor {
    associatedtype Value
    
    func next() -> Result<(data: Value, end: Bool), Error>

    /// Сбрасывает свойства итератора
    func renew()
}
