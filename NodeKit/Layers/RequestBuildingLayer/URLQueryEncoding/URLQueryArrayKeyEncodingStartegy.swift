import Foundation

/// Протокол для любого кодировщика URL-Query ключа для массива.
public protocol URLQueryArrayKeyEncodingStartegy {
    /// Кодирует ключ массива, который затем используется в URL-Query как ключ элемента.
    ///
    /// - Warning:
    /// Использование по-умолчанию не требует специально кодировать значение в string-url.
    /// Достаточно просто вернуть нужное строковое представление
    ///
    /// - Parameter value: Значение, которое нужно закодировать
    func encode(value: String) -> String
}

/// Реализация кодировщика `URLQueryArrayKeyEncodingStartegy` по-умолчанию.
/// Поддерживает две стратегии:
/// - brackets: ключ запишется как `key[]`
/// - noBrackets: ключ запишется как `key`
///
/// - Examples:
///
/// ```
/// let query = ["sortKeys": ["value", "date", "price"]]
/// URLQueryArrayKeyEncodingBracketsStartegy.brackets.encode(value: "sortKeys")
///
/// ```
/// Выведет: `sortKeys[]` и URL-Query в итоге должен будет выглядеть так: `sortKeys[]=value&sortKeys[]=date&sortKeys[]=price`
///
/// ```
/// let query = ["sortKeys": ["value", "date", "price"]]
/// URLQueryArrayKeyEncodingBracketsStartegy.noBrackets.encode(value: "sortKeys")
/// ```
/// Выведет: `sortKeys` и URL-Query в итоге должен будет выглядеть так: `sortKeys=value&sortKeys=date&sortKeys=price`
public enum URLQueryArrayKeyEncodingBracketsStartegy: URLQueryArrayKeyEncodingStartegy {
    case brackets
    case noBrackets

    /// Кодирует ключ массива в ключ для URL-query в зависимости от выбранной стратегии.
    ///
    /// - Parameter value: Значение, которое нужно закодировать
    public func encode(value: String) -> String {
        switch self {
        case .brackets:
            return "\(value)[]"
        case .noBrackets:
            return value
        }
    }
}
