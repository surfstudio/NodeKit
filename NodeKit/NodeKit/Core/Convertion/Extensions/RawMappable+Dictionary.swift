import Foundation

/// This extension allows representing a dictionary as ``RawMappable``.
extension Dictionary: RawMappable where Dictionary.Key == String, Dictionary.Value == Any {

    /// Returns itself.
    /// - Throws: Does not throw errors.
    public func toRaw() throws -> Json {
        return self
    }

    /// Returns the ``Json`` received as input.
    /// - Throws: Does not throw errors.
    public static func from(raw: Json) throws -> Json {
        return raw
    }
}
