import Foundation

/// Модель для отправки multipart запросов.
/// Позволяет передавать как файлы, так и просто данные.
open class MultipartModel<T> {

    /// Обычные данные для запроса.
    public let payloadModel: T
    /// Набор файлов для запроса.
    public let files: [String: MultipartFileProvider]

    /// Основной конструктор.
    ///
    /// - Parameters:
    ///   - payloadModel: Обычные данные для запроса.
    ///   - files: Набор файлов для запроса.
    public required init(payloadModel: T, files: [String: MultipartFileProvider]) {
        self.payloadModel = payloadModel
        self.files = files
    }

    /// Дополнительный конструктор. Инициаллизирует объект пустым набором файлов.
    ///
    /// - Parameter payloadModel: Обычные данные для запроса.
    public convenience init(payloadModel: T) {
        self.init(payloadModel: payloadModel, files: [String: MultipartFileProvider]())
    }
}


public extension MultipartModel where T == StubEmptyModel<[String: Data]> {

    /// Дополнительный конструктор. Позволяет инициаллизировать модель только одними файлами.
    ///
    /// - Parameter files: Набор файлов для запроса.
    convenience init(files: [String: MultipartFileProvider]) {
        self.init(payloadModel: StubEmptyModel<[String: Data]>(), files: files)
    }
}
