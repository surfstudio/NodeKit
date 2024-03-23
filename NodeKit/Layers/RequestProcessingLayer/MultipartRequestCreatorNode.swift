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
open class MultipartRequestCreatorNode<Output>: AsyncNode {
    /// Следующий узел для обработки.
    public var next: any AsyncNode<URLRequest, Output>

    /// Инициаллизирует узел.
    ///
    /// - Parameter next: Следующий узел для обработки.
    public init(next: any AsyncNode<URLRequest, Output>) {
        self.next = next
    }

    /// Конфигурирует низкоуровненвый запрос.
    ///
    /// - Parameter data: Данные для конфигурирования и последующей отправки запроса.
    open func process(_ data: MultipartUrlRequest) -> Observer<Output> {
        do {
            var request = URLRequest(url: data.url)
            request.httpMethod = data.method.rawValue

            // Add Headers
            data.headers.forEach { request.addValue($0.key, forHTTPHeaderField: $0.value) }

            // Form Data
            let formData = MultipartFormData(fileManager: FileManager.default)
            append(multipartForm: formData, with: data)
            request.setValue(formData.contentType, forHTTPHeaderField: "Content-Type")
            let encodedFormData = try formData.encode()
            request.httpBody = encodedFormData

            return self.next.process(request).log(self.getLogMessage(data))
        } catch {
            return .emit(error: error)
        }
    }

    /// Конфигурирует низкоуровненвый запрос.
    ///
    /// - Parameter data: Данные для конфигурирования и последующей отправки запроса.
    open func process(
        _ data: MultipartUrlRequest,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<Output> {
        return await .withMappedExceptions {
            var request = URLRequest(url: data.url)
            request.httpMethod = data.method.rawValue

            // Add Headers
            data.headers.forEach { request.addValue($0.key, forHTTPHeaderField: $0.value) }

            // Form Data
            let formData = MultipartFormData(fileManager: FileManager.default)
            append(multipartForm: formData, with: data)
            request.setValue(formData.contentType, forHTTPHeaderField: "Content-Type")
            let encodedFormData = try formData.encode()
            request.httpBody = encodedFormData

            await logContext.add(getLogMessage(data))
            return await next.process(request, logContext: logContext)
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
