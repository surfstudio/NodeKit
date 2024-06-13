import Foundation

/// Protocol for any boolean value encoder into URL query.
public protocol URLQueryBoolEncodingStartegy {

    /// Encodes the boolean value into a string for URL query.
    ///
    /// - Warning:
    /// Using the default implementation does not require specially encoding the value into a string-url.
    /// It is sufficient to return the required string representation.
    ///
    /// - Parameter value: The value to encode.
    func encode(value: Bool) -> String
}

/// Default implementation of the boolean value encoder.
/// Supports two encoding strategies:
/// - asInt:
///     - false -> 0
///     - true -> 1
/// - asBool:
///     - false -> "false"
///     - true -> "true"
public enum URLQueryBoolEncodingDefaultStartegy: URLQueryBoolEncodingStartegy {
    case asInt
    case asBool

    /// Encodes the boolean value into a string for URL query depending on the selected strategy.
    ///
    /// - Parameter value: The value to encode.
    public func encode(value: Bool) -> String {
        switch self {
        case .asInt:
            return value ? "1" : "0"
        case .asBool:
            return value ? "true" : "false"
        }
    }
}
