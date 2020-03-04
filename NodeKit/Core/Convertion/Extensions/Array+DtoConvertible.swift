import Foundation

/// Позволяетп редставлять массив с элементами `DTODecodable` как `DTODecodable` в случае, если `Raw == Json`
extension Array: DTODecodable where Element: DTODecodable, Element.DTO.Raw == Json {

    public typealias DTO = Array<Element.DTO>

    public static func from(dto: DTO) throws -> Array<Element> {
        return try dto.map { try Element.from(dto: $0) }
    }
}

/// Позволяетп редставлять массив с элементами `DTOEncodable` как `DTOEncodable` в случае, если `Raw == Json`
extension Array: DTOEncodable where Element: DTOEncodable, Element.DTO.Raw == Json {
    public func toDTO() throws -> Array<Element.DTO> {
        return try self.map { try $0.toDTO() }
    }
}
