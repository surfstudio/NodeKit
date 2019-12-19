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
open class ResponseDataParserNode: Node<UrlDataResponse, Json> {

    /// Следующий узел для обработки.
    public var next: ResponsePostprocessorLayerNode?

    /// Инициаллизирует узел.
    ///
    /// - Parameter next: Следующий узел для обработки.
    public init(next: ResponsePostprocessorLayerNode? = nil) {
        self.next = next
    }

    /// Парсит ответ и в случае успеха передает управление следующему узлу.
    ///
    /// - Parameter data: Модель овтета сервера.
    open override func process(_ data: UrlDataResponse) -> Observer<Json> {

        let context = Context<Json>()
        var json = Json()
        var log = self.logViewObjectName

        do {
            let (raw, logMsg) = try self.json(from: data)
            json = raw
            log += logMsg + .lineTabDeilimeter
        } catch {
            switch error {
            case ResponseDataParserNodeError.cantCastDesirializedDataToJson(let logMsg), ResponseDataParserNodeError.cantDeserializeJson(let logMsg):
                log += logMsg
            default:
                log += "Catch \(error)"
            }

            context.log(Log(log, id: self.objectName, order: LogOrder.responseDataParserNode)).emit(error: error)
            return context
        }

        guard let nextNode = next else {

            log += "Next node is nil -> terminate chain process"
            return context.log(Log(log, id: self.objectName, order: LogOrder.responseDataParserNode)).emit(data: json)
        }

        log += "Have next node \(nextNode.objectName) -> call `process`"

        let networkResponse = UrlProcessedResponse(dataResponse: data, json: json)

        return nextNode.process(networkResponse).log(Log(log, id: self.objectName, order: LogOrder.responseDataParserNode)).map { json }
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
}

