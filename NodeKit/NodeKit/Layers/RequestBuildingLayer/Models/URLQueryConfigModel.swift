import Foundation

/// Модель, хранящая конфигурацию для `URLQueryInjectorNode`
public struct URLQueryConfigModel {
    /// Модель из которой создается URL-query.
    public var query: [String: Any]

    /// Стратегия для кодирования булевых значений.
    /// - SeeAlso: `URLQueryBoolEncodingDefaultStartegy`
    public var boolEncodingStartegy: URLQueryBoolEncodingStartegy

    /// Стратегия для кодирования ключа массива.
    /// - SeeAlso: `URLQueryArrayKeyEncodingBracketsStartegy`
    public var arrayEncodingStrategy: URLQueryArrayKeyEncodingStartegy

    /// Стратегия для кодирования ключа словаря.
    /// - SeeAlso: `URLQueryDictionaryKeyEncodingDefaultStrategy`
    public var dictEncodindStrategy: URLQueryDictionaryKeyEncodingStrategy

    /// Инициллизирует структуру.
    /// - Parameter query: Модель из которой создается URL-query.
    /// - Parameter boolEncodingStartegy: Стратегия для кодирования булевых значений.
    /// - Parameter arrayEncodingStrategy: Стратегия для кодирования ключа массива.
    /// - Parameter dictEncodindStrategy: Стратегия для кодирования ключа словаря.
    public init(query: [String: Any],
                boolEncodingStartegy: URLQueryBoolEncodingStartegy,
                arrayEncodingStrategy: URLQueryArrayKeyEncodingStartegy,
                dictEncodindStrategy: URLQueryDictionaryKeyEncodingStrategy) {

        self.query = query
        self.boolEncodingStartegy = boolEncodingStartegy
        self.arrayEncodingStrategy = arrayEncodingStrategy
        self.dictEncodindStrategy = dictEncodindStrategy
    }

    /// Инцииаллизирует структуру с дефолтными параметрами стратегий.
    /// - Parameter query: Модель из которой создается URL-query.
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
