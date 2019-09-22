import Foundation

/// Протокол для сущности, которая может создать заглушку своего типа.
/// Например для словаря это будет пустой словарь
public protocol Stubable {
    static func stub() -> Self
}

/// Позволяет словарю стать заглушкой.
extension Dictionary: Stubable {
    public static func stub() -> [Key: Value] {
        return [Key: Value]()
    }
}

/// Модель - заглушка. Может использоваться в том случае, когда нужна какая-то сущность,
/// но писать код не хочется.
public struct StubEmptyModel<T: Stubable>: DTOConvertible, RawMappable {

    public typealias DTO = StubEmptyModel<T>
    public typealias Raw = T

    public func toRaw() throws -> Raw {
        return T.stub()
    }

    public static func from(raw: Raw) throws -> StubEmptyModel<Raw> {
        return .init()
    }

    public func toDTO() throws -> StubEmptyModel<T> {
        return self
    }

    public static func from(dto: StubEmptyModel<T>) throws -> StubEmptyModel<T> {
        return dto
    }
}
