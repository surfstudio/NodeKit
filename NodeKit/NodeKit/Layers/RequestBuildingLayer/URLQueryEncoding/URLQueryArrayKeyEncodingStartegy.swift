import Foundation

/// Protocol for any URL query key encoder for an array.
public protocol URLQueryArrayKeyEncodingStartegy {
    /// Encodes the array key, which is then used in the URL query as the key of the element.
    ///
    /// - Warning:
    /// Using the default implementation does not require specially encoding the value into a string-url.
    /// It is sufficient to return the required string representation.
    ///
    /// - Parameter value: The value to encode.
    func encode(value: String) -> String
}

/// Default implementation of the `URLQueryArrayKeyEncodingStartegy`.
/// Supports two strategies:
/// - brackets: the key will be written as `key[]`
/// - noBrackets: the key will be written as `key`
///
/// - Examples:
///
/// ```
/// let query = ["sortKeys": ["value", "date", "price"]]
/// URLQueryArrayKeyEncodingBracketsStartegy.brackets.encode(value: "sortKeys")
///
/// ```
/// - Output: `sortKeys[]=value&sortKeys[]=date&sortKeys[]=price`
///
/// ```
/// let query = ["sortKeys": ["value", "date", "price"]]
/// URLQueryArrayKeyEncodingBracketsStartegy.noBrackets.encode(value: "sortKeys")
/// ```
/// - Output: `sortKeys=value&sortKeys=date&sortKeys=price`
public enum URLQueryArrayKeyEncodingBracketsStartegy: URLQueryArrayKeyEncodingStartegy {
    case brackets
    case noBrackets

    /// Encodes the array key into a key for the URL query depending on the selected strategy.
    ///
    /// - Parameter value: The value to encode.
    public func encode(value: String) -> String {
        switch self {
        case .brackets:
            return "\(value)[]"
        case .noBrackets:
            return value
        }
    }
}
