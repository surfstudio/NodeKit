//
//  AsyncIterator.swift
//  NodeKit

/// Интерфейс любого асинхронно интерируемого компонента
///
/// pageSize, offset и другие параметры указываются в конкретной реализации протокола
public protocol AsyncIterator<Value>: Actor {
    associatedtype Value
    
    /// Requests next data.
    @discardableResult
    func next() async -> Result<Value, Error>
    
    /// Returns whether there is more data.
    func hasNext() -> Bool

    /// Resets the iterator.
    func renew()
}
