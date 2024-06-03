import Foundation

/// Errors for mapping arrays to/from ``Json``
///
/// - cantFindKeyInRaw: Occurs if the `MappingUtils.arrayJsonKey` key cannot be found during ``Json`` array parsing.
public enum ErrorArrayJsonMappiong: Error {
    case cantFindKeyInRaw(Json)
}

/// In the case where JSON is represented only as an array.
/// For example, the JSON looks like this:
/// ```
/// [
///     { ... },
///     { ... },
///       ...
/// ]
/// ```
/// The array needs to be wrapped in a dictionary.
public enum MappingUtils {
    /// The key under which the array will be included in the dictionary.
    public static var arrayJsonKey = "_array"
}

/// Contains the implementation of mapping an array to ``Json``.
extension Array: RawEncodable where Element: RawEncodable, Element.Raw == Json {

    public func toRaw() throws -> Json {
        let arrayData = try self.map { try $0.toRaw() }

        return [MappingUtils.arrayJsonKey: arrayData]
    }

}

/// Contains the implementation of mapping ``Json`` to an array.
extension Array: RawDecodable where Element: RawDecodable, Element.Raw == Json {

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
