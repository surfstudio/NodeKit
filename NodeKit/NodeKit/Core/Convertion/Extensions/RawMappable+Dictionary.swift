import Foundation

/// This extension allows representing a dictionary as ``RawMappable``.
extension Dictionary: RawMappable where Dictionary.Key == String, Dictionary.Value == Any {

    /// Returns itself.
    /// - Throws: Does not throw errors.
    public func toRaw() throws -> Json {
        return self
    }

    /// Just returns the input.
    /// - Throws: Does not throw errors.
    public static func from(raw: Json) throws -> Json {
        return raw
    }
}
