import Foundation

/// The composition of protocols ``DTOEncodable`` and ``DTODecodable``.
public typealias DTOConvertible = DTOEncodable & DTODecodable

/// Describes an entity from the upper DTO layer.
/// Can convert itself to the DTO layer.
public protocol DTOEncodable {
    /// DTO entity type.
    associatedtype DTO: RawEncodable

    /// Retrieves the lower-level DTO model from itself.
    ///
    /// - Returns: The conversion result.
    /// - Throws: Any user-defined exceptions may occur.
    func toDTO() throws -> DTO
}

/// Describes an entity from the upper DTO layer.
/// Can convert the DTO layer into itself.
public protocol DTODecodable {
    /// DTO entity type.
    associatedtype DTO: RawDecodable

    /// Converts a model from the lower-level DTO into a model of the upper-level DTO.
    ///
    /// - Parameter from: The lower-level DTO model from which to obtain the upper-level model.
    /// - Returns: The conversion result.
    /// - Throws: Any user-defined exceptions may occur.
    static func from(dto: DTO) throws -> Self
}

/// Allowing one-line mapping of optional models.
public extension Optional where Wrapped: DTODecodable {
    static func from(dto: Wrapped.DTO?) throws -> Wrapped? {
        guard let guarded = dto else {
            return nil
        }

        return try Wrapped.from(dto: guarded)
    }
}
