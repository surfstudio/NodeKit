import Foundation

/// Allows representing an array with elements of ``DTODecodable`` as ``DTODecodable`` if Raw == ``Json``.
extension Array: DTODecodable where Element: DTODecodable, Element.DTO.Raw == Json {

    public typealias DTO = Array<Element.DTO>

    public static func from(dto: DTO) throws -> Array<Element> {
        return try dto.map { try Element.from(dto: $0) }
    }
}

/// Allows representing an array with elements of ``DTOEncodable`` as ``DTOEncodable`` if Raw == ``Json``.
extension Array: DTOEncodable where Element: DTOEncodable, Element.DTO.Raw == Json {
    public func toDTO() throws -> Array<Element.DTO> {
        return try self.map { try $0.toDTO() }
    }
}
