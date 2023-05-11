//
//  ResponseBsonDataPreprocessorNode.swift
//  NodeKit
//
//  Created by Vladislav Krupenko on 31.03.2020.
//  Copyright © 2020 Кравченков Александр. All rights reserved.
//

import Foundation
import BSON
import NodeKit

/// Этот узел занимается десериализаций данных ответа в `Bson`.
/// В случае 204-го ответа далее передает пустой `Bson`.
open class ResponseBsonDataPreprocessorNode: BsonResponseProcessingLayerNode {

    /// Следующий узел для обработки.
    public var next: BsonResponseProcessingLayerNode

    /// Инициаллизирует узел.
    ///
    /// - Parameter next: Следующий узел для обработки.
    public init(next: BsonResponseProcessingLayerNode) {
        self.next = next
    }

    /// Сериализует "сырые" данные в `Bson`
    ///
    /// - Parameter data: Представление ответа.
    open override func process(_ data: UrlDataResponse) -> Observer<Bson> {
        var log = Log(self.logViewObjectName, id: self.objectName, order: LogOrder.responseDataPreprocessorNode)

        guard data.response.statusCode != 204 else {
            log += "Status code is 204 -> response data is empty -> terminate process with empty bson"
            return Context<Bson>().emit(data: Bson()).log(log)
        }

        if Document(data: data.data).count == 0 {
            log += "Json serialization sucess but json is empty -> terminate process with empty bson"
        }

        return self.next.process(data)
    }

}
