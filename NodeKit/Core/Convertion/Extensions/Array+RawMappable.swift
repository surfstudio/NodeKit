import Foundation

/// Ошибки для маппинга массивов в/из JSON
///
/// - cantFindKeyInRaw: Возникает в случае если при парсинге JSON-массива не удалось найти ключ `MappingUtils.arrayJsonKey`
public enum ErrorArrayJsonMappiong: Error {
    case cantFindKeyInRaw(Json)
}

/// В том случае, когда JSON представлен тлько массивом.
/// Например JSON выглядит вот так:
/// ```
/// [
///     { ... },
///     { ... },
///       ...
/// ]
/// ```
/// Необходимо оборачивать массив в словарь.
public enum MappingUtils {
    /// Ключ по которому массив будет включен в словарь.
    public static var arrayJsonKey = "_array"
}

/// Содержит реализацию маппинга массива в JSON
extension Array: RawMappable where Element: RawMappable, Element.Raw == Json {

    public typealias Raw = Json

    public func toRaw() throws -> Json {
        let arrayData = try self.map { try $0.toRaw() }

        return [MappingUtils.arrayJsonKey: arrayData]
    }

    public static func from(raw: Json) throws -> Array<Element> {

        guard !raw.isEmpty else {
            return [Element]()
        }

        guard let arrayData = raw[MappingUtils.arrayJsonKey] as? [Json] else {
            throw ErrorArrayJsonMappiong.cantFindKeyInRaw(raw)
        }

        return try arrayData.map { try Element.from(raw: $0) }
    }
}
