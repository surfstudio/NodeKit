import Foundation
import NodeKitThirdParty

/// Model for internal representation of a multipart request.
public struct MultipartURLRequest {

    /// HTTP method.
    public let method: Method
    /// URL endpoint.
    public let url: URL
    /// Request headers.
    public let headers: [String: String]
    /// Request data.
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

/// Node capable of creating a multipart request.
open class MultipartRequestCreatorNode<Output>: AsyncNode {
    
    // MARK: - Public Properties
    
    /// The next node for processing.
    public var next: any AsyncNode<URLRequest, Output>
    
    // MARK: - Private Properties
    
    private let multipartFormDataFactory: MultipartFormDataFactory

    /// Initializer.
    ///
    /// - Parameter next: The next node for processing.
    public init(
        next: any AsyncNode<URLRequest, Output>,
        multipartFormDataFactory: MultipartFormDataFactory = AlamofireMultipartFormDataFactory()
    ) {
        self.next = next
        self.multipartFormDataFactory = multipartFormDataFactory
    }

    /// Configures the low-level request.
    ///
    /// - Parameter data: Data for configuring and subsequently sending the request.
    open func process(
        _ data: MultipartURLRequest,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<Output> {
        let formData = multipartFormDataFactory.produce()
        append(multipartForm: formData, with: data)
        
        return await .withMappedExceptions {
            return .success(try formData.encode())
        }
        .asyncFlatMap { encodedData in
            var request = URLRequest(url: data.url)
            request.httpMethod = data.method.rawValue
            
            data.headers.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }
            
            request.setValue(formData.contentType, forHTTPHeaderField: "Content-Type")
            request.httpBody = encodedData
            
            return await .withCheckedCancellation {
                await logContext.add(getLogMessage(data))
                return await next.process(request, logContext: logContext)
            }
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
