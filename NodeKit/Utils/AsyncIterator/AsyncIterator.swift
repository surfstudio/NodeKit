//
//  AsyncIterator.swift
//  NodeKit

/// Интерфейс любого асинхронно интерируемого компонента
///
/// pageSize, offset и другие параметры указываются в конкретной реализации протокола
protocol AsyncIteratorLegacy {

    /// Тип эленмента пагинируемой коллекции
    associatedtype Value

    /// Возвращает следующую страницу
    /// Если смещение 0, то запросит первую и вернет её
    ///
    /// Кастомное поведение можно написать в своей реализации
    func next() -> Observer<Value>

    /// Сбрасывает свойства итератора
    func renew()

    func onEnd(_ closure: @escaping () -> Void)
}

public protocol AsyncIterator: Actor {
    associatedtype Value
    
    func next() -> Result<(data: Value, end: Bool), Error>

    /// Сбрасывает свойства итератора
    func renew()
}
