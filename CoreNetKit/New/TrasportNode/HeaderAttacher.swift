//
//  JsonNetworkProcessing.swift
//  CoreNetKitWithExample
//
//  Created by Александр Кравченков on 27/11/2018.
//  Copyright © 2018 Александр Кравченков. All rights reserved.
//

import Foundation
import Alamofire

class HeaderAttacher<Input>: Node<RequestModel<Input>, CoreNetKitJson> {

    private let next: Node<RequestModel<Input>, CoreNetKitJson>

    init(next: Node<RequestModel<Input>, CoreNetKitJson>) {
        self.next = next
    }

    override func input(_ data: RequestModel<Input>) -> Context<CoreNetKitJson> {
        data.headers["CUSTOM HEADER KEY"] = "CUSTOM HEADER VALUE"
        return next.input(data)
    }
}
