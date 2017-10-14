//
//  ServerResponse.swift
//  Sample
//
//  Created by Alexander Kravchenkov on 06.07.17.
//  Copyright © 2017 Alexander Kravchenkov. All rights reserved.
//

import Foundation
import Alamofire

public class ServerError: LocalizedError {

    private struct Keys {
        public static let id = "id"
        public static let message = "message"
    }

    private(set) var id: String
    private(set) var message: String?

    public init(id: String, message: String?) {
        self.id = id
        self.message = message
    }

    public convenience init?(with json: [String: Any]) {

        guard let guardedId = json[Keys.id] as? String else {
            return nil
        }
        self.init(id: guardedId, message: json[Keys.message] as? String)
    }

    public var errorDescription: String? {
        return self.message
    }
}

class ServerResponse: NSObject {

    // MARK: - Consts
    private struct Const {
        public static let succesCode = 200
        public static let notModifiedCode = 304
        public static let firstErrorCode = 300
        public static let networkErrorCode = -1009
        public static let emptyRessponseBodyCode = 204
    }

    // MARK: - Fileds

    var httpResponse: HTTPURLResponse?
    let statusCode: Int
    var notModified: Bool
    var connectionFailed: Bool
    var result: ResponseResult<Any>
    private(set) var errorMapper: ErrorMapperAdapter?

    // MARK: - Initializers

    /// For creatin Cached responses
    internal override init() {
        self.statusCode = Const.succesCode
        self.notModified = true
        self.connectionFailed = false
        self.result = .failure(BaseCacheError.cantFindInCache)
        super.init()
    }

    init(dataResponse: DefaultDataResponse?, dataResult: ResponseResult<Data?>, errorMapper: ErrorMapperAdapter? = nil) {
        self.httpResponse = dataResponse?.response
        let statusCode = self.httpResponse?.statusCode ?? 0
        self.statusCode = statusCode
        self.notModified = self.statusCode == Const.notModifiedCode
        self.connectionFailed = false
        self.errorMapper = errorMapper
        self.result = .failure(BaseServerError.undefind)
        super.init()
        if (dataResponse?.error as NSError?)?.code == Const.networkErrorCode {
            self.result = .failure(BaseServerError.networkError)
            self.connectionFailed = true
            return
        }

        self.result = {
            guard statusCode != Const.emptyRessponseBodyCode else {
                return .success([String: Any](), dataResult.isCached)
            }

            // kostil
            // TODO: Think about it
            guard let guardData = dataResult.value else {
                return  .failure(BaseServerError.undefind)
            }

            // https://en.wikipedia.org/wiki/List_of_HTTP_status_codes
            if statusCode >= Const.firstErrorCode || statusCode < Const.succesCode {
                return .failure(self.parseError(data: guardData))
            } else if let object = self.trySerializeToJson(data: guardData) {
                return .success(object, dataResult.isCached)
            } else {
                return .failure(BaseServerError.badJsonFormat)
            }
        }()
    }
}

// MARK: - Error parsing extensions

private extension ServerResponse {

    func trySerializeToJson(data: Data?) -> Any? {
        return try? JSONSerialization.jsonObject(with: data ?? Data(), options: .allowFragments)
    }

    func parseError(data: Data?) -> LocalizedError {
        guard let error = self.trySerializeToJson(data: data) else {
            return BaseServerError.badJsonFormat
        }
        guard let customError = self.errorMapper?.map(json: error) else {
            return BaseServerError.undefind
        }

        return customError
    }
}
