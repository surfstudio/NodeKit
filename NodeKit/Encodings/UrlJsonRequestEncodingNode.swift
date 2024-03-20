//
//  UrlJsonRequestEncodingNode.swift
//  NodeKit
//
//  Created by Vladislav Krupenko on 06.05.2020.
//  Copyright © 2020 Кравченков Александр. All rights reserved.
//

import Foundation

open class UrlJsonRequestEncodingNode<Type>: Node {

    /// Следующий узел для обработки.
    public var next: any Node<TransportUrlRequest, Type>

    /// Инициаллизирует узел.
    ///
    /// - Parameters:
    ///   - next: Следйющий узел для обработки.
    public init(next: some Node<TransportUrlRequest, Type>) {
        self.next = next
    }

    open func process(_ data: RequestEncodingModel) -> Observer<Type> {
        var log = getLogMessage(data)
        let request: TransportUrlRequest?
        let paramEncoding = { () -> ParameterEncoding? in
            guard data.urlParameters.method == .get else {
                return data.encoding?.raw
            }
            return URLEncoding.default
        }()
        guard let encoding = paramEncoding else {
            log += "Missed encoding type -> terminate with error"
            return Context<Type>().log(log).emit(error: RequestEncodingNodeError.missedJsonEncodingType)
        }
        do {
            request = try encoding.encode(urlParameters: data.urlParameters, parameters: data.raw)
            log.message += "type: Json"
        } catch {
            log += "But can't encode data -> terminate with error"
            return Context<Type>().log(log).emit(error: RequestEncodingError.unsupportedDataType)
        }

        guard let unwrappedRequest = request else {
            log += "Unsupported data type -> terminate with error"
            return Context<Type>().log(log).emit(error: RequestEncodingError.unsupportedDataType)
        }

        return next.process(unwrappedRequest).log(log)
    }

    open func process(
        _ data: RequestEncodingModel,
        logContext: LoggingContextProtocol
    ) async -> Result<Type, Error> {
        var log = getLogMessage(data)
        let paramEncoding = parameterEncoding(from: data)

        guard let encoding = paramEncoding else {
            log += "Missed encoding type -> terminate with error"
            await logContext.add(log)
            return .failure(RequestEncodingNodeError.missedJsonEncodingType)
        }
        do {
            let request = try encoding.encode(urlParameters: data.urlParameters, parameters: data.raw)
            log += "type: Json"
            return await next.process(request, logContext: logContext)
        } catch {
            log += "But can't encode data -> terminate with error"
            await logContext.add(log)
            return .failure(RequestEncodingError.unsupportedDataType)
        }
    }

    // MARK: - Private Methods

    private func parameterEncoding(from data: RequestEncodingModel) -> ParameterEncoding? {
        guard data.urlParameters.method == .get else {
            return data.encoding?.raw
        }
        return URLEncoding.default
    }

    private func getLogMessage(_ data: RequestEncodingModel) -> Log {
        let message = "<<<===\(self.objectName)===>>>\n" +
            "input: \(type(of: data))" +
            "encoding: \(String(describing: data.encoding))" +
            "raw: \(String(describing: data.raw))"
        return Log(message, id: self.objectName, order: LogOrder.requestEncodingNode)
    }
}
