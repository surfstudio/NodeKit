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

//        nodeKitBsonRequest()
//        urlSessionBsonPostRequest()
        nodeKitBsonPostRequest()
    }

    func nodeKitBsonRequest() {
//        SomeService().getBson()
//            .onCompleted { userEntity in
//                print(userEntity)
//            }.onError { error in
//                print(error)
//            }.onCanceled {
//                print("cancel called")
//            }.defer {
//                print("defer called")
//            }
    }

    func nodeKitBsonPostRequest() {
        let userEntity = UserEntity(id: "123", firstName: "Freeze", lastName: "John")
        SomeService().postBson(with: userEntity)
            .onCompleted { _ in
                print("done")
            }.onError { error in
                print(error.localizedDescription)
            }.defer {
                print("defer")
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

    func urlSessionBsonPostRequest() {
        guard let url = URL(string: "http://localhost:8118/nkt/bson") else {
            return
        }

        let document: Document = [
            "id": "123",
            "firstname": "Freeze",
            "lastname": "John"
        ]
        var request = URLRequest(url: url)
        request.method = .post
        request.httpBody = document.makeData()
        request.addValue("application/bson", forHTTPHeaderField: "Content-Type")
        request.addValue("application/bson", forHTTPHeaderField: "Accept")

        dataTask = defaultSession.dataTask(with: request, completionHandler: { [weak self] data, response, error in
            defer {
                self?.dataTask = nil
            }
            print(response)
            if let error = error {
                print(error.localizedDescription)
            } else if let data = data {
                print(data)
            } else {
                print("some shit")
            }
        })
        dataTask?.resume()
    }

}

struct UserEntity {
    let id: String
    let firstName: String
    let lastName: String
}

extension UserEntity: DTOConvertible {

    typealias DTO = Document

    public static func from(dto model: Document) throws -> UserEntity {
        let id = (model["id"] as? String) ?? ""
        let firstName = (model["firstname"] as? String) ?? ""
        let lastName = (model["lastname"] as? String) ?? ""
        return .init(id: id, firstName: firstName, lastName: lastName)
    }

    func toDTO() throws -> Document {
        let document: Document = [
            "id": id,
            "firstname": firstName,
            "lastname": lastName
        ]
        return document
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

//    func getBson() -> Observer<UserEntity> {
//        return BsonChain()
//            .route(.get, .loadBson)
//            .build()
//            .process()
//    }

    func postBson(with entity: UserEntity) -> Observer<Void> {
        return BsonChain()
            .route(.post, .loadBson)
            .build()
            .process(entity)

    }

}
