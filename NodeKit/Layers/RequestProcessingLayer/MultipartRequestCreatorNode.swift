import Foundation

/// Модель для внутреннего представления multipart запроса.
public struct MultipartUrlRequest {

    /// HTTP метод.
    public let method: Method
    /// URL эндпоинта.
    public let url: URL
    /// Хедеры запроса.
    public let headers: [String: String]
    /// Данные для запроса.
    public let data: MultipartModel<[String: Data]>

    public init(method: Method,
                url: URL,
                headers: [String: String],
                data: MultipartModel<[String: Data]>) {
        self.method = method
        self.url = url
        self.headers = headers
        self.data = data
    }
}

/// Узел, умеющий создавать multipart-запрос.
open class MultipartRequestCreatorNode<Output>: Node<MultipartUrlRequest, Output> {
    /// Следующий узел для обработки.
    public var next: Node<URLRequest, Output>

    /// Инициаллизирует узел.
    ///
    /// - Parameter next: Следующий узел для обработки.
    public init(next: Node<URLRequest, Output>) {
        self.next = next
    }

    /// Конфигурирует низкоуровненвый запрос.
    ///
    /// - Parameter data: Данные для конфигурирования и последующей отправки запроса.
    open override func process(_ data: MultipartUrlRequest) -> Observer<Output> {

        let formData = MultipartFormData(fileManager: FileManager.default)
        append(multipartForm: formData, with: data)
        do {
            var request = URLRequest(url: data.url, method: data.method, headers: HTTPHeaders(data.headers))
            let encodedFormData = try formData.encode()
            request.setValue(formData.contentType, forHTTPHeaderField: "Content-Type")
            request.httpBody = encodedFormData
            return self.next.process(request).log(self.getLogMessage(data))
        } catch {
            return .emit(error: error)
        }
    }

    private func getLogMessage(_ data: MultipartUrlRequest) -> Log {
        var message = "<<<===\(self.objectName)===>>>\n"
        message += "input: \(type(of: data))\n\t"
        message += "method: \(data.method.rawValue)\n\t"
        message += "url: \(data.url.absoluteString)\n\t"
        message += "headers: \(data.headers)\n\t"
        message += "parametersEncoding: multipart)"

        return Log(message, id: self.objectName, order: LogOrder.requestCreatorNode)
    }

    open func append(multipartForm: MultipartFormData, with request: MultipartUrlRequest) {
        request.data.payloadModel.forEach { key, value in
            multipartForm.append(value, withName: key)
        }
        request.data.files.forEach { key, value in
            switch value {
            case .data(data: let data, filename: let filename, mimetype: let mimetype):
                multipartForm.append(data, withName: key, fileName: filename, mimeType: mimetype)
            case .url(url: let url):
                multipartForm.append(url, withName: key)
            case .customWithUrl(url: let url, filename: let filename, mimetype: let mimetype):
                multipartForm.append(url, withName: key, fileName: filename, mimeType: mimetype)
            }
        }
    }
}
