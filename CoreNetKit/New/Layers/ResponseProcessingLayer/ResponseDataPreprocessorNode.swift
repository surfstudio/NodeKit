//
//  ResponseDataProcessorNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 04/02/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

public enum ResponseDataProcessorNodeError: Error {
    case cantExtractHTTPResponse
    case cantDerializeJson
}

open class ResponseDataPreprocessorNode: ResponseProcessingLayerNode {

    public var next: ResponseProcessingLayerNode

    public init(next: ResponseProcessingLayerNode) {
        self.next = next
    }

    open override func process(_ data: UrlDataResponse) -> Observer<Json> {

        guard data.response.statusCode != 204 else {
            return Context<Json>().emit(data: Json())
        }

        if let jsonObject = try? JSONSerialization.jsonObject(with: data.data, options: .allowFragments), jsonObject is NSNull {
            return Context<Json>().emit(data: Json())
        }

        return self.next.process(data)
    }
}
