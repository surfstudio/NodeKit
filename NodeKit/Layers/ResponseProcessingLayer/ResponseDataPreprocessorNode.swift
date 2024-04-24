//
//  ResponseDataProcessorNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 04/02/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// Этот узел занимается десериализаций данных ответа в `JSON`.
/// В случае 204-го ответа далее передает пустой `Json`.
open class ResponseDataPreprocessorNode: AsyncNode {

    /// Следующий узел для обработки.
    public var next: any ResponseProcessingLayerNode

    /// Инициаллизирует узел.
    ///
    /// - Parameter next: Следующий узел для обработки.
    public init(next: some ResponseProcessingLayerNode) {
        self.next = next
    }

    /// Сериализует "сырые" данные в `Json`
    ///
    /// - Parameter data: Представление ответа.
    open func processLegacy(_ data: UrlDataResponse) -> Observer<Json> {
        var log = Log(self.logViewObjectName, id: self.objectName, order: LogOrder.responseDataPreprocessorNode)

        guard data.response.statusCode != 204 else {
            log += "Status code is 204 -> response data is empty -> terminate process with empty json"
            return Context<Json>().emit(data: Json()).log(log)
        }

        if let jsonObject = try? JSONSerialization.jsonObject(with: data.data, options: .allowFragments), jsonObject is NSNull {
            log += "Json serialization sucess but json is NSNull -> terminate process with empty json"
            return Context<Json>().emit(data: Json()).log(log)
        }

        return self.next.processLegacy(data)
    }

    /// Сериализует "сырые" данные в `Json`
    ///
    /// - Parameter data: Представление ответа.
    open func process(
        _ data: UrlDataResponse,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<Json> {
        var log = Log(logViewObjectName, id: objectName, order: LogOrder.responseDataPreprocessorNode)

        guard data.response.statusCode != 204 else {
            log += "Status code is 204 -> response data is empty -> terminate process with empty json"
            await logContext.add(log)
            return .success(Json())
        }

        if let jsonObject = try? JSONSerialization.jsonObject(
                with: data.data,
                options: .allowFragments
            ), 
            jsonObject is NSNull 
        {
            log += "Json serialization sucess but json is NSNull -> terminate process with empty json"
            await logContext.add(log)
            return .success(Json())
        }

        return await next.process(data, logContext: logContext)
    }
}
