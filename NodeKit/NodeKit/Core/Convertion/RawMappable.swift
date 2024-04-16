import Foundation

/// Словарь вида `[String: Any]`
public typealias Json = [String: Any]

/// Композиция `RawEncodable` и `RawDecodable`
public typealias RawMappable = RawEncodable & RawDecodable

/// Описывает сущность из нижнего слоя DTO.
/// Может конвертировать себя в RAW (например JSON).
public protocol RawEncodable {

    /// Тип данных, в которые мапятся модели. Напрмиер JSON
    associatedtype Raw

    /// Конвертирет модель в RAW
    /// - Returns: RAW-представление модели
    /// - Throws: Могут возникать любые исключения, определенные пользователем.
    func toRaw() throws -> Raw
}

/// Описывает сущность из нижнего слоя DTO.
/// Может мапить RAW на себя.
public protocol RawDecodable {

    /// Тип данных, в которые мапятся модели. Напрмиер JSON

    associatedtype Raw

    /// Преобразует данные в RAW формате в модель.
    ///
    /// - Parameter from: Данные в RAW формате
    /// - Returns: модель полученная из RAW
    /// - Throws: Могут возникать любые исключения, определенные пользователем.
    static func from(raw: Raw) throws -> Self
}

/// Синтаксический сахар, позволяющий в одну строчку мапить опциональные модели.
public extension Optional where Wrapped: RawDecodable {
    static func from(raw: Wrapped.Raw?) throws -> Wrapped? {
        guard let guarded = raw else {
            return nil
        }

        return try Wrapped.from(raw: guarded)
    }
}
