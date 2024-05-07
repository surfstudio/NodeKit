import Foundation

/// Протокол для любого кодировщика булевского значения в URL-query.
public protocol URLQueryBoolEncodingStartegy {

    /// Кодирует булевое значение в строку для URL-query.
    ///
    /// - Warning:
    /// Использование по-умолчанию не требует специально кодировать значение в string-url.
    /// Достаточно просто вернуть нужное строковое представление
    ///
    /// - Parameter value: Значение, которое нужно закодировать
    func encode(value: Bool) -> String
}

/// Дефолтная имплементация кодировщика булевских значений.
/// Поддерживает две стратегии кодирование:
/// - asInt:
///     - false -> 0
///     - true -> 1
/// - asBool:
///     - false -> "false"
///     - true -> "true"
public enum URLQueryBoolEncodingDefaultStartegy: URLQueryBoolEncodingStartegy {
    case asInt
    case asBool

    /// Кодирует булевое значение в строку для URL-query в зависимости от выбранной стратегии. 
    ///
    /// - Parameter value: Значение, которое нужно закодировать
    public func encode(value: Bool) -> String {
        switch self {
        case .asInt:
            return value ? "1" : "0"
        case .asBool:
            return value ? "true" : "false"
        }
    }
}
