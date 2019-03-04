//
//  JsonNetworkProcessing.swift
//  CoreNetKitWithExample
//
//  Created by Александр Кравченков on 27/11/2018.
//  Copyright © 2018 Александр Кравченков. All rights reserved.
//

import Foundation
import Alamofire

/// This node provide possibility to add any header fileds to request
open class HeaderAttacher<Input>: Node<RequestModel<Input>, CoreNetKitJson> {

    private let next: Node<RequestModel<Input>, CoreNetKitJson>

    private let headers: [String: String]

    public init(next: Node<RequestModel<Input>, CoreNetKitJson>, headers: [String: String]) {
        self.next = next
        self.headers = headers
    }

    open override func process(_ data: RequestModel<Input>) -> Context<CoreNetKitJson> {
        data.headers.merge(self.headers) { (lhs, rhs) -> String in
            return rhs
        }
        return next.process(data)
    }
}
