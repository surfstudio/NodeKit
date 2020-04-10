import Foundation

/// Модель, хранящая конфигурацию для `URLQueryInjectorNode`
public struct URLQueryConfigModel {
    /// Модель из которой создается URL-query.
    public var query: [String: Any] {
        get {
            var allParameters = _query
            paginationModel?.query.forEach {
                allParameters[$0] = $1
            }
            return allParameters
        }
        set {
            _query = newValue
        }
    }

    /// Стратегия для кодирования булевых значений.
    /// - SeeAlso: `URLQueryBoolEncodingDefaultStartegy`
    public var boolEncodingStartegy: URLQueryBoolEncodingStartegy

    /// Стратегия для кодирования ключа массива.
    /// - SeeAlso: `URLQueryArrayKeyEncodingBracketsStartegy`
    public var arrayEncodingStrategy: URLQueryArrayKeyEncodingStartegy

    /// Стратегия для кодирования ключа словаря.
    /// - SeeAlso: `URLQueryDictionaryKeyEncodingDefaultStrategy`
    public var dictEncodindStrategy: URLQueryDictionaryKeyEncodingStrategy

    /// Модель пагинации запросов - позволяет отдельно отслеживать параметры именно для пагинации
    public var paginationModel: PaginationModel?

    // MARK - Private properties

    private var _query: [String: Any]

    /// Инициллизирует структуру.
    /// - Parameter query: Модель из которой создается URL-query.
    /// - Parameter boolEncodingStartegy: Стратегия для кодирования булевых значений.
    /// - Parameter arrayEncodingStrategy: Стратегия для кодирования ключа массива.
    /// - Parameter dictEncodindStrategy: Стратегия для кодирования ключа словаря.
    public init(query: [String: Any],
                boolEncodingStartegy: URLQueryBoolEncodingStartegy,
                arrayEncodingStrategy: URLQueryArrayKeyEncodingStartegy,
                dictEncodindStrategy: URLQueryDictionaryKeyEncodingStrategy,
                paginationModel: PaginationModel?) {

        self._query = query
        self.boolEncodingStartegy = boolEncodingStartegy
        self.arrayEncodingStrategy = arrayEncodingStrategy
        self.dictEncodindStrategy = dictEncodindStrategy
        self.paginationModel = paginationModel
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
                  dictEncodindStrategy: URLQueryDictionaryKeyEncodingDefaultStrategy(),
                  paginationModel: nil)
    }

}
