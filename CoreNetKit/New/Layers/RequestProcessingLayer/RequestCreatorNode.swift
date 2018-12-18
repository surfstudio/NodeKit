//
//  RequestSenderNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 18/12/2018.
//  Copyright © 2018 Кравченков Александр. All rights reserved.
//

import Foundation
import Alamofire

public class ServerRequestsManager {

    static let shared = ServerRequestsManager()

    let manager: SessionManager

    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForResource = 60 * 3
        configuration.timeoutIntervalForRequest = 60 * 3
        configuration.requestCachePolicy = .reloadIgnoringCacheData
        configuration.urlCache = nil
        self.manager = Alamofire.SessionManager(configuration: configuration)
    }
}

extension CoreNetKit.Method {
    var http: HTTPMethod {
        switch self {
        case .get:
            return .get
        case .post:
            return .post
        case .put:
            return .put
        case .delete:
            return .delete
        }
    }
}

public struct RawUrlRequest {
    let dataRequest: DataRequest

    func toUrlRequest() -> UrlNetworkRequest? {

        guard let urlRequest = self.dataRequest.request else {
            return nil
        }

        return UrlNetworkRequest(urlRequest: urlRequest)
    }
}

open class RequestCreatorNode: Node<TransportUrlRequest, Json> {

    public var next: Node<RawUrlRequest, Json>

    public init(next: Node<RawUrlRequest, Json>) {
        self.next = next
    }

    open override func process(_ data: TransportUrlRequest) -> Context<Json> {
        let manager = ServerRequestsManager.shared.manager

        let paramEncoding = {() -> ParameterEncoding in
            return data.method == .get ? URLEncoding.default : JSONEncoding.default
        }()

        let request = manager.request(
            data.url,
            method: data.method.http,
            parameters: data.raw,
            encoding: paramEncoding,
            headers: data.headers
        )

        return self.next.process(RawUrlRequest(dataRequest: request))
    }
}
