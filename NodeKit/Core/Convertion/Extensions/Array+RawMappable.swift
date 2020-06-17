import Foundation

/// Ошибки для маппинга массивов в/из `Raw`, где `Raw` это `JSON` или `BSON`
///
/// - cantFindKeyInRaw: Возникает в случае если при парсинге JSON-массива не удалось найти ключ `MappingUtils.arrayJsonKey`
public enum ErrorArrayRawMapping: Error {
    case cantFindKeyInRaw(Json)
    case cantFindArrayInBson(Bson)
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
extension Array: RawEncodable where Element: RawEncodable, Element.Raw == Json {

    public func toRaw() throws -> Json {
        let arrayData = try self.map { try $0.toRaw() }

        return [MappingUtils.arrayJsonKey: arrayData]
    }

}

/// Содержит реализацию маппинга JSON в массив
extension Array: RawDecodable where Element: RawDecodable, Element.Raw == Json {

    public static func from(raw: Json) throws -> Array<Element> {

        guard !raw.isEmpty else {
            return [Element]()
        }

        guard let arrayData = raw[MappingUtils.arrayJsonKey] as? [Json] else {
            throw ErrorArrayRawMapping.cantFindKeyInRaw(raw)
        }

        return try arrayData.map { try Element.from(raw: $0) }
    }
}

extension Array where Element: RawEncodable, Element.Raw == Bson {

    public func toRaw() throws -> Bson {
        let arrayData = try self.map { try $0.toRaw() }
        return Bson(array: arrayData)
    }

}

extension Array where Element: RawDecodable, Element.Raw == Bson {

    public static func from(raw: Bson) throws -> Array<Element> {
        guard !raw.isEmpty else {
            return [Element]()
        }
        guard raw.isArray else {
            throw ErrorArrayRawMapping.cantFindArrayInBson(raw)
        }
        let arrayData = raw.values.compactMap { $0 as? Bson }
        return try arrayData.map { try Element.from(raw: $0) }
    }

}
