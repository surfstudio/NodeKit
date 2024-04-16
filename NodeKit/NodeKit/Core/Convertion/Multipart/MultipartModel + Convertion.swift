import Foundation

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
