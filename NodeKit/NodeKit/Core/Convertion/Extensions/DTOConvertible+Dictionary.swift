import Foundation

/// This extension allows representing a dictionary as ``DTOConvertible``.
extension Dictionary: DTOConvertible where Dictionary.Key == String, Dictionary.Value == Any {

    public typealias DTO = Json

    public func toDTO() throws -> Json {
        return self
    }

    public static func from(dto: Json) throws -> [String: Any] {
        return dto
    }
}
