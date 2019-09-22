import Foundation

public enum MultipartFileProvider {
    case data(data: Data, filename: String, mimetype: String)
    case url(url: URL)
    case urlAndName(url: URL, filename: String, mimetype: String)
}

public protocol Stubable {
    static func stub() -> Self
}

extension Dictionary: Stubable {
    public static func stub() -> [Key: Value] {
        return [Key: Value]()
    }
}

public struct EmptyModel<T: Stubable>: DTOConvertible, RawMappable {

    public typealias DTO = EmptyModel<T>
    public typealias Raw = T

    public func toRaw() throws -> Raw {
        return T.stub()
    }

    public static func from(raw: Raw) throws -> EmptyModel<Raw> {
        return .init()
    }

    public func toDTO() throws -> EmptyModel<T> {
        return self
    }

    public static func from(dto: EmptyModel<T>) throws -> EmptyModel<T> {
        return dto
    }
}

open class MultipartModel<T> {

    public let payloadModel: T
    public let files: [String: MultipartFileProvider]

    public required init(payloadModel: T, files: [String: MultipartFileProvider]) {
        self.payloadModel = payloadModel
        self.files = files
    }

    public convenience init(payloadModel: T) {
        self.init(payloadModel: payloadModel, files: [String: MultipartFileProvider]())
    }
}

public extension MultipartModel where T == EmptyModel<[String: Data]> {
    convenience init(files: [String: MultipartFileProvider]) {
        self.init(payloadModel: EmptyModel<[String: Data]>(), files: files)
    }
}

extension MultipartModel: DTOConvertible where T: DTOConvertible {

    public static func from(dto: MultipartModel<T.DTO>) throws -> Self {
        return try .init(payloadModel: .from(dto: dto.payloadModel), files: dto.files)
    }

    public func toDTO() throws -> MultipartModel<T.DTO> {
        return try .init(payloadModel: self.payloadModel.toDTO(), files: self.files)
    }
}

extension MultipartModel: RawMappable where T: RawMappable {

    public typealias Raw = MultipartModel<T.Raw>

    public func toRaw() throws -> MultipartModel<T.Raw> {
        return try .init(payloadModel: self.payloadModel.toRaw(), files: self.files)
    }

    public static func from(raw: MultipartModel<T.Raw>) throws -> Self {
        return try .init(payloadModel: .from(raw: raw.payloadModel), files: raw.files)
    }
}
