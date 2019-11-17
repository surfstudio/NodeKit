import Foundation

/// Протокол для любого кодировщика URL-Query ключа для словаря.
public protocol URLQueryDictionaryKeyEncodingStrategy {
    /// Кодирует ключ словаря, который затем используется в URL-Query как ключ элемента.
    ///
    /// - Warning:
    /// Использование по-умолчанию не требует специально кодировать значение в string-url.
    /// Достаточно просто вернуть нужное строковое представление
    ///
    /// - Parameter value: Значение, которое нужно закодировать
    func encode(queryItemName: String, dictionaryKey: String) -> String
}

/// Реализация кодировщика `URLQueryDictionaryKeyEncodingStrategy` по-умолчанию.
///
/// - Example:
///
/// ```
/// let query = ["key": [
///     "name": "bob",
///     "age": 23
/// ]
/// URLQueryDictionaryKeyEncodingDefaultStrategy().encode(queryItemName: "key", dictionaryKey: "name")
///
/// ```
public struct URLQueryDictionaryKeyEncodingDefaultStrategy: URLQueryDictionaryKeyEncodingStrategy {

    /// Кодирует ключ словаря в ключ для URL-query.
    ///
    /// - Parameter value: Значение, которое нужно закодировать
    public func encode(queryItemName: String, dictionaryKey: String) -> String {
        return "\(queryItemName)[\(dictionaryKey)]"
    }
}
