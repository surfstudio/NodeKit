import Foundation

public protocol DataProvider {
    func provide() -> Data
}

extension Data: DataProvider {
    public func provide() -> Data {
        return self
    }
}

open class MultipartModel<T> {

    open var payloadModel: T
    open var payloadData: [String: DataProvider]

    public required init(payloadModel: T, payloadData: [String: DataProvider]) {
        self.payloadModel = payloadModel
        self.payloadData = payloadData
    }
}

extension MultipartModel: DTOConvertible where T: DTOConvertible {


    public static func from(dto: MultipartModel<T.DTO>) throws -> Self {
        return try .init(payloadModel: .from(dto: dto.payloadModel), payloadData: dto.payloadData)
    }

    public func toDTO() throws -> MultipartModel<T.DTO> {
        return try .init(payloadModel: self.payloadModel.toDTO(), payloadData: self.payloadData)
    }
}

extension MultipartModel: RawMappable where T: RawMappable {

    public typealias Raw = MultipartModel<T.Raw>

    public func toRaw() throws -> MultipartModel<T.Raw> {
        return try .init(payloadModel: self.payloadModel.toRaw(), payloadData: self.payloadData)
    }

    public static func from(raw: MultipartModel<T.Raw>) throws -> Self {
        return try .init(payloadModel: .from(raw: raw.payloadModel), payloadData: raw.payloadData)
    }
}
