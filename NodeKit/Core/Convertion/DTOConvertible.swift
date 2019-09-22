import Foundation

/// Композиция протоколов `DTOEncodable` и `DTODecodable`
public typealias DTOConvertible = DTOEncodable & DTODecodable

/// Описывает сущность из верхнего слоя DTO.
/// Может конвертировать себя в слой DTO
public protocol DTOEncodable {
    /// Тип сущности DTO.
    associatedtype DTO: RawEncodable

    /// Получает DTO-модель нижнего уровня из себя.
    ///
    /// - Returns: Результат конвертирования.
    /// - Throws: Могут возникать любе исключения, определенные пользователем.
    func toDTO() throws -> DTO
}

/// Описывает сущность из верхнего слоя DTO.
/// Может ковертироать слой DTO в себя.
public protocol DTODecodable {
    /// Тип сущности DTO.
    associatedtype DTO: RawDecodable

    /// Кнвертирует модель из DTO нижнего уровня в DTO-модель верхнего уровня.
    ///
    /// - Parameter from: Модель нижнего уровня DTO из которой необходимо получить модель верхнего уровня.
    /// - Returns: Результат конвертирования.
    /// - Throws: Могут возникать любе исключения, определенные пользователем.
    static func from(dto: DTO) throws -> Self
}

/// Синтаксический сахар, позволяющий в одну строчку мапить опциональные модели.
public extension Optional where Wrapped: DTODecodable {
    static func from(dto: Wrapped.DTO?) throws -> Wrapped? {
        guard let guarded = dto else {
            return nil
        }

        return try Wrapped.from(dto: guarded)
    }
}
