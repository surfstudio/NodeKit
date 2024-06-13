import Foundation

/// Protocol for any URL query key encoder for a dictionary.
public protocol URLQueryDictionaryKeyEncodingStrategy {
    /// Encodes the dictionary key, which is then used in the URL query as the key of the element.
    ///
    /// - Warning:
    /// Using the default implementation does not require specially encoding the value into a string-url.
    /// It is sufficient to return the required string representation.
    ///
    /// - Parameter value: The value to encode.
    func encode(queryItemName: String, dictionaryKey: String) -> String
}

/// Default implementation of the ``URLQueryDictionaryKeyEncodingStrategy``.
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

    /// Encodes the dictionary key into a key for the URL query.
    ///
    /// - Parameter value: The value to encode.
    public func encode(queryItemName: String, dictionaryKey: String) -> String {
        return "\(queryItemName)[\(dictionaryKey)]"
    }
}
