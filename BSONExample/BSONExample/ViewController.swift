//
//  ViewController.swift
//  BSONExample
//
//  Created by Vladislav Krupenko on 31.03.2020.
//  Copyright © 2020 Fixique. All rights reserved.
//

import UIKit
import NodeKit
import Alamofire
import BSON

class ViewController: UIViewController {

    let defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?

    override func viewDidLoad() {
        super.viewDidLoad()

        nodeKitBsonRequest()
    }

    func nodeKitBsonRequest() {
        SomeService().loadBson()
            .onCompleted { userEntity in
                print(userEntity)
            }.onError { error in
                print(error)
            }.onCanceled {
                print("cancel called")
            }.defer {
                print("defer called")
            }
    }


    func urlSessionBsonRequest() {
        guard let url = URL(string: "http://localhost:8118/nkt/bson") else {
            return
        }
        dataTask = defaultSession.dataTask(with: url, completionHandler: { [weak self] data, response, error in
            defer {
                self?.dataTask = nil
            }
            if let error = error {
                print(error.localizedDescription)
            } else if let data = data {
                let document = Document(data: data)
                print(document)
            } else {
                print("some shit")
            }
        })
        dataTask?.resume()
    }

}

extension Data {
    public var bytes: Array<UInt8> {
      Array(self)
    }
}

extension Document: RawMappable {
    public static func from(raw: Bson) throws -> Document {
        return raw
    }

    public func toRaw() throws -> Bson {
        return self
    }

    public typealias Raw = Bson
}

struct UserEntity {
    let id: String
    let firstName: String
    let lastName: String
}

extension UserEntity: DTODecodable {

    typealias DTO = Document

    public static func from(dto model: Document) throws -> UserEntity {
        let id = (model["id"] as? String) ?? ""
        let firstName = (model["firstname"] as? String) ?? ""
        let lastName = (model["lastname"] as? String) ?? ""
        return .init(id: id, firstName: firstName, lastName: lastName)
    }

}

/// Service chain for user desk api with custom error parsers
final class BsonServiceChain: UrlServiceChainBuilder {

    override func urlResponseBsonProcessingLayerChain() -> Node<DataResponse<Data>, Bson> {
        let responseDataParserNode = ResponseBsonDataParserNode()
        let responseDataPreprocessorNode = ResponseBsonDataPreprocessorNode(next: responseDataParserNode)
        let responseHttpErrorProcessorNode = ResponseHttpErrorProcessorNode(next: responseDataPreprocessorNode)
        return ResponseProcessorNode(next: responseHttpErrorProcessorNode)
    }

//    override func requestTrasportChain() -> TransportLayerNode {
//        let requestSenderNode = RequestSenderNode(rawResponseProcessor: self.urlResponseProcessingLayerChain())
//        let technicalErrorMapperNode = TechnicaErrorMapperNode(next: requestSenderNode)
//        return RequestCreatorNode(next: technicalErrorMapperNode)
//    }

}

enum Endpoint: UrlRouteProvider {
    case loadBson

    func url() throws -> URL {
        switch self {
        case .loadBson:
            return try .from("http://localhost:8118/nkt/bson")
        }
    }

}

enum CustomError: Error {
    case badUrl
}

extension URL {
    static func from(_ string: String) throws -> URL {
        guard let url = URL(string: string) else {
            throw CustomError.badUrl
        }
        return url
    }
}


final class BsonChain: UrlBsonChainsBuilder<Endpoint> {

    override init(serviceChain: UrlServiceChainBuilder = BsonServiceChain()) {
        super.init(serviceChain: serviceChain)
    }

}


class SomeService {

    func loadBson() -> Observer<UserEntity> {
        return BsonChain()
            .route(.get, .loadBson)
            .build()
            .process()
    }

}
