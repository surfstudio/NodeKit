//
//  ResponseDataParserNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 04/02/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// Ошибки для узлы `ResponseDataParserNode`
///
/// - cantDeserializeJson: Возникает в случае, если не удалось получить `Json` из ответа сервера.
/// - cantCastDesirializedDataToJson: Возникает в случае, если из `Data` не удалось сериализовать `JSON`
public enum ResponseDataParserNodeError: Error {
    case cantDeserializeJson(String)
    case cantCastDesirializedDataToJson(String)
}

/// Выполняет преобразование преобразование "сырых" данных в `Json`
/// - SeeAlso: `MappingUtils`
open class ResponseDataParserNode: AsyncNode {

    /// Следующий узел для обработки.
    public var next: (any ResponsePostprocessorLayerNode)?

    /// Инициаллизирует узел.
    ///
    /// - Parameter next: Следующий узел для обработки.
    public init(next: (any ResponsePostprocessorLayerNode)? = nil) {
        self.next = next
    }

    /// Парсит ответ и в случае успеха передает управление следующему узлу.
    ///
    /// - Parameter data: Модель ответа сервера.
    open func process(
        _ data: UrlDataResponse,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<Json> {
        return await parse(with: data, logContext: logContext)
            .asyncFlatMap { json, logMessage in
                let logMsg = logViewObjectName + logMessage + .lineTabDeilimeter
                var log = Log(logMsg, id: objectName, order: LogOrder.responseDataParserNode)

                guard let next = next else {
                    log += "Next node is nil -> terminate chain process"
                    await logContext.add(log)
                    return .success(json)
                }

                let networkResponse = UrlProcessedResponse(dataResponse: data, json: json)

                log += "Have next node \(next.objectName) -> call `process`"

                await logContext.add(log)
                await next.process(networkResponse, logContext: logContext)

                return .success(json)
            }
    }

    /// Получает `json` из модели ответа сервера.
    /// Содержит всю логику парсинга.
    ///
    /// - Parameter responseData: Модель ответа сервера.
    /// - Returns: Json, которй удалось распарсить.
    /// - Throws:
    ///     - `ResponseDataParserNodeError.cantCastDesirializedDataToJson`
    ///     - `ResponseDataParserNodeError.cantDeserializeJson`
    open func json(from responseData: UrlDataResponse) throws -> (Json, String) {

        var log = ""

        guard responseData.data.count != 0 else {
            log += "Response data is empty -> returns empty json"
            return (Json(), log)
        }

        guard let jsonObject = try? JSONSerialization.jsonObject(with: responseData.data, options: .allowFragments) else {
            log += "Cant deserialize \(String(describing: String(data: responseData.data, encoding: .utf8)))"
            throw ResponseDataParserNodeError.cantCastDesirializedDataToJson(log)
        }

        let anyJson = { () -> Json? in
            if let result = jsonObject as? [Any] {
                return [MappingUtils.arrayJsonKey: result]
            } else if let result = jsonObject as? Json {
                return result
            } else {
                return nil
            }
        }()

        guard let json = anyJson else {
            log += "After parsing get nil json"
            throw ResponseDataParserNodeError.cantDeserializeJson(log)
        }

        if let data = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
            log += "Result:" + .lineTabDeilimeter
            log += String(data: data, encoding: .utf8) ?? "CURRUPTED"
        }

        return (json, log)
    }

    // MARK: - Private Methods

    private func parse(
        with data: UrlDataResponse,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<(Json, String)> {
        do {
            let result = try json(from: data)
            return .success(result)
        } catch {
            var log = Log(logViewObjectName, id: objectName, order: LogOrder.responseDataParserNode)
            switch error {
            case ResponseDataParserNodeError.cantCastDesirializedDataToJson(let logMsg), 
                ResponseDataParserNodeError.cantDeserializeJson(let logMsg):
                log += logMsg
            default:
                log += "Catch \(error)"
            }
            await logContext.add(log)
            return .failure(error)
        }
    }
}
