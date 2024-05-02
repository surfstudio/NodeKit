import Foundation
import NodeKitThirdParty

/// Модель для внутреннего представления multipart запроса.
public struct MultipartURLRequest {

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
    
    // MARK: - Public Properties
    
    /// Следующий узел для обработки.
    public var next: any AsyncNode<URLRequest, Output>
    
    // MARK: - Private Properties
    
    private let multipartFormDataFactory: MultipartFormDataFactory

    /// Инициаллизирует узел.
    ///
    /// - Parameter next: Следующий узел для обработки.
    public init(
        next: any AsyncNode<URLRequest, Output>,
        multipartFormDataFactory: MultipartFormDataFactory = AlamofireMultipartFormDataFactory()
    ) {
        self.next = next
        self.multipartFormDataFactory = multipartFormDataFactory
    }

    /// Конфигурирует низкоуровневый запрос.
    ///
    /// - Parameter data: Данные для конфигурирования и последующей отправки запроса.
    open func process(
        _ data: MultipartURLRequest,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<Output> {
        return await .withMappedExceptions {
            var request = URLRequest(url: data.url)
            request.httpMethod = data.method.rawValue

            // Add Headers
            data.headers.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }

            // Form Data
            let formData = multipartFormDataFactory.produce()
            append(multipartForm: formData, with: data)
            request.setValue(formData.contentType, forHTTPHeaderField: "Content-Type")
            let encodedFormData = try formData.encode()
            request.httpBody = encodedFormData

            await logContext.add(getLogMessage(data))
            return await next.process(request, logContext: logContext)
        }
    }

    private func getLogMessage(_ data: MultipartURLRequest) -> Log {
        var message = "<<<===\(self.objectName)===>>>\n"
        message += "input: \(type(of: data))\n\t"
        message += "method: \(data.method.rawValue)\n\t"
        message += "url: \(data.url.absoluteString)\n\t"
        message += "headers: \(data.headers)\n\t"
        message += "parametersEncoding: multipart)"

        return Log(message, id: self.objectName, order: LogOrder.requestCreatorNode)
    }

    open func append(multipartForm: MultipartFormDataProtocol, with request: MultipartURLRequest) {
        request.data.payloadModel.forEach { key, value in
            multipartForm.append(value, withName: key)
        }
        request.data.files.forEach { key, value in
            switch value {
            case .data(data: let data, filename: let filename, mimetype: let mimetype):
                multipartForm.append(data, withName: key, fileName: filename, mimeType: mimetype)
            case .url(url: let url):
                multipartForm.append(url, withName: key)
            case .customWithURL(url: let url, filename: let filename, mimetype: let mimetype):
                multipartForm.append(url, withName: key, fileName: filename, mimeType: mimetype)
            }
        }
    }
}