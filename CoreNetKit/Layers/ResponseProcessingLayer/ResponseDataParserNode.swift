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
    case cantDeserializeJson
    case cantCastDesirializedDataToJson
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

        do {
            json = try self.json(from: data)
        } catch {
            context.emit(error: error)
            return context
        }

        guard let nextNode = next else {
            return context.emit(data: json)
        }

        let networkResponse = UrlProcessedResponse(dataResponse: data, json: json)

        return nextNode.process(networkResponse).map { json }
    }

    /// Получает `json` из модели ответа сервера.
    /// Содержит всю логику парсинга.
    ///
    /// - Parameter responseData: Модель ответа сервера.
    /// - Returns: Json, которй удалось распарсить.
    /// - Throws:
    ///     - `ResponseDataParserNodeError.cantCastDesirializedDataToJson`
    ///     - `ResponseDataParserNodeError.cantDeserializeJson`
    open func json(from responseData: UrlDataResponse) throws -> Json {
        guard responseData.data.count != 0 else {
            return Json()
        }
        guard let jsonObject = try? JSONSerialization.jsonObject(with: responseData.data, options: .allowFragments) else {
            throw ResponseDataParserNodeError.cantCastDesirializedDataToJson
        }

        let anyJson = { () -> Json? in
            if let result = jsonObject as? [Json] {
                return [MappingUtils.arrayJsonKey: result]
            } else if let result = jsonObject as? Json {
                return result
            } else {
                return nil
            }
        }()

        guard let json = anyJson else {
            throw ResponseDataParserNodeError.cantDeserializeJson
        }

        return json
    }
}

