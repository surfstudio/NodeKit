//
//  JsonNetworkNode.swift
//  CoreNetKitWithExample
//
//  Created by Александр Кравченков on 27/11/2018.
//  Copyright © 2018 Александр Кравченков. All rights reserved.
//

import Foundation
import Alamofire

enum BaseJsonNetworkNodeError: Error {
    case cantMapToJson
    case responseDataIsNil
}


class JsonNetworkNode: Node<RequestModel<CoreNetKitJson>, CoreNetKitJson> {

    private let manager: ServerRequestsManager
    private let next: Node<RawUrlRequest, CoreNetKitJson>

    init(with manager: ServerRequestsManager = ServerRequestsManager.shared, next: Node<RawUrlRequest, CoreNetKitJson>) {
        self.manager = manager
        self.next = next
    }

    override func process(_ data: RequestModel<CoreNetKitJson>) -> Context<CoreNetKitJson> {
        let manager = ServerRequestsManager.shared.manager

        let paramEncoding = {() -> ParameterEncoding in
            return data.method == .get ? URLEncoding.default : JSONEncoding.default
        }()

        let request = manager.request(
            data.url,
            method: data.method.http,
            parameters: data.model,
            encoding: paramEncoding,
            headers: data.headers
        )

        return self.next.process(RawUrlRequest(dataRequest: request))
    }
}
