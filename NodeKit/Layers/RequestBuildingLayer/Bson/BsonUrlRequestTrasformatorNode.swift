//
//  BsonUrlRequestTrasformatorNode.swift
//  NodeKit
//
//  Created by Vladislav Krupenko on 02.04.2020.
//  Copyright © 2020 Кравченков Александр. All rights reserved.
//

import Foundation

open class BsonUrlRequestTransformatorNode<Type>: Node<EncodableRequestModel<UrlRouteProvider, Bson, ParametersEncoding>, Type> {

    /// Следйющий узел для обработки.
    public var next: Node<TransportUrlBsonRequest, Type>

    /// HTTP метод для запроса.
    public var method: Method

    /// Инициаллизирует узел.
    ///
    /// - Parameters:
    ///   - next: Следйющий узел для обработки.
    ///   - method: HTTP метод для запроса.
    public init(next: Node<TransportUrlBsonRequest, Type>, method: Method) {
        self.next = next
        self.method = method
    }

    /// Конструирует модель для для работы на транспортном уровне цепочки.
    ///
    /// - Parameter data: Данные для дальнейшей обработки.
    open override func process(_ data: EncodableRequestModel<UrlRouteProvider, Bson, ParametersEncoding>) -> Observer<Type> {

        var url: URL

        do {
            url = try data.route.url()
        } catch {
            return .emit(error: error)
        }

        let params = TransportUrlParameters(method: self.method,
                                            url: url,
                                            headers: data.metadata,
                                            parametersEncoding: data.encoding)

        let request = TransportUrlBsonRequest(with: params, raw: data.raw)

        return next.process(request)
    }
}
