import Foundation

/// Model storing configuration for ``URLQueryInjectorNode``.
public struct URLQueryConfigModel {
    /// Model from which the URL query is created.
    public var query: [String: Any]

    /// Startegy for encoding boolean values.
    public var boolEncodingStartegy: URLQueryBoolEncodingStartegy

    /// Startegy for encoding array key.
    public var arrayEncodingStrategy: URLQueryArrayKeyEncodingStartegy

    /// Strategy for encoding dictionary key.
    public var dictEncodindStrategy: URLQueryDictionaryKeyEncodingStrategy

    /// Initializes the structure.
    /// - Parameter query: Model from which the URL query is created.
    /// - Parameter boolEncodingStartegy: Startegy for encoding boolean values.
    /// - Parameter arrayEncodingStrategy: Startegy for encoding array key.
    /// - Parameter dictEncodindStrategy: Strategy for encoding dictionary key.
    public init(query: [String: Any],
                boolEncodingStartegy: URLQueryBoolEncodingStartegy,
                arrayEncodingStrategy: URLQueryArrayKeyEncodingStartegy,
                dictEncodindStrategy: URLQueryDictionaryKeyEncodingStrategy) {

        self.query = query
        self.boolEncodingStartegy = boolEncodingStartegy
        self.arrayEncodingStrategy = arrayEncodingStrategy
        self.dictEncodindStrategy = dictEncodindStrategy
    }

    /// Initializes the structure with default strategy parameters.
    /// - Parameter query: Model from which the URL query is created.
    ///
    /// - Info:
    ///     - `boolEncodingStartegy` = `URLQueryBoolEncodingDefaultStartegy.asInt`
    ///     - `arrayEncodingStrategy` = `URLQueryArrayKeyEncodingBracketsStartegy.brackets`
    ///     - `dictEncodindStrategy` = `URLQueryDictionaryKeyEncodingDefaultStrategy`
    public init(query: [String: Any]) {
        self.init(query: query,
                  boolEncodingStartegy: URLQueryBoolEncodingDefaultStartegy.asInt,
                  arrayEncodingStrategy: URLQueryArrayKeyEncodingBracketsStartegy.brackets,
                  dictEncodindStrategy: URLQueryDictionaryKeyEncodingDefaultStrategy())
    }
}
