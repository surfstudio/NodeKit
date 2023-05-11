//
//  ResponseBsonDataParserNode.swift
//  NodeKit
//
//  Created by Vladislav Krupenko on 31.03.2020.
//  Copyright © 2020 Кравченков Александр. All rights reserved.
//

import Foundation
import BSON
import NodeKit

open class ResponseBsonDataParserNode: BsonResponseProcessingLayerNode {

    /// Следующий узел для обработки.
    public var next: BsonResponsePostprocessorLayerNode?

    /// Инициаллизирует узел.
    ///
    /// - Parameter next: Следующий узел для обработки.
    public init(next: BsonResponsePostprocessorLayerNode? = nil) {
        self.next = next
    }

    open override func process(_ data: UrlDataResponse) -> Observer<Bson> {
        let context = Context<Bson>()
        let bson: Bson
        var log = self.logViewObjectName

        let (raw, logMsg) = self.bson(from: data)
        bson = raw
        log += logMsg + .lineTabDeilimeter

        guard let nextNode = next else {
            log += "Next node is nil -> terminate chain process"
            return context.log(Log(log, id: self.objectName, order: LogOrder.responseDataParserNode)).emit(data: bson)
        }

        log += "Have next node \(nextNode.objectName) -> call `process`"

        let networkResponse = UrlProcessedResponse(dataResponse: data, type: bson)

        return nextNode.process(networkResponse).log(Log(log, id: self.objectName, order: LogOrder.responseDataParserNode)).map { bson }
    }

    open func bson(from responseData: UrlDataResponse) -> (Bson, String) {
        var log = ""

        let bsonDocument = Document(data: responseData.data)

        guard responseData.data.count != 0, bsonDocument.count != 0 else {
            log += "Response data is empty -> returns empty bson"
            return (Bson(), log)
        }

        log += "Result:" + .lineTabDeilimeter
        log += bsonDocument.debugDescription

        return (bsonDocument, log)
    }

}
