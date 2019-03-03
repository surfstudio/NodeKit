//
//  ResponseDataParserNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 04/02/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

public enum ResponseDataParserNodeError: Error {
    case cantDerializeJson
    case cantCastDesirializedDataToJson
}

open class ResponseDataParserNode: Node<UrlDataResponse, Json> {

    public var next: ResponsePostprocessorLayrNode?

    public init(next: ResponsePostprocessorLayrNode? = nil) {
        self.next = next
    }

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

    open func json(from responseData: UrlDataResponse) throws -> Json {
        guard responseData.data.count != 0 else {
            return Json()
        }
        guard let jsonObject = try? JSONSerialization.jsonObject(with: responseData.data, options: .allowFragments) else {
            throw ResponseDataParserNodeError.cantDerializeJson
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
            throw ResponseDataParserNodeError.cantCastDesirializedDataToJson
        }

        return json
    }
}

