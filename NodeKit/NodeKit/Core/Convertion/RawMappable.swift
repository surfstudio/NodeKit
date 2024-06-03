import Foundation

/// Dictionary of type `[String: Any]`.
public typealias Json = [String: Any]

/// Composition of ``RawEncodable`` and ``RawDecodable``.
public typealias RawMappable = RawEncodable & RawDecodable

/// Describes an entity from the lower DTO layer.
/// Can convert itself to RAW (for example, ``Json``).
public protocol RawEncodable {

    /// Data type to which models are mapped. For example, ``Json``.
    associatedtype Raw

    /// Converts the model to RAW.
    /// - Returns: The RAW representation of the model.
    /// - Throws: Any user-defined exceptions may occur.
    func toRaw() throws -> Raw
}

/// Describes an entity from the lower DTO layer.
/// Can map RAW to itself.
public protocol RawDecodable {

    /// Data type to which models are mapped. For example, ``Json``.
    associatedtype Raw

    /// Converts data in RAW format to a model.
    ///
    /// - Parameter from: Data in RAW format.
    /// - Returns: The model obtained from RAW.
    /// - Throws: Any user-defined exceptions may occur.
    static func from(raw: Raw) throws -> Self
}

/// Syntactic sugar that allows mapping optional models in one line.
public extension Optional where Wrapped: RawDecodable {
    static func from(raw: Wrapped.Raw?) throws -> Wrapped? {
        guard let guarded = raw else {
            return nil
        }

        return try Wrapped.from(raw: guarded)
    }
}
