//
//  ServerResponse.swift
//  Sample
//
//  Created by Alexander Kravchenkov on 06.07.17.
//  Copyright © 2017 Alexander Kravchenkov. All rights reserved.
//

import Foundation
import Alamofire

public class BaseCoreServerResponse: NSObject, CoreServerResponse {

    // MARK: - Consts
    private struct Const {
        public static let succesCode = 200
        public static let notModifiedCode = 304
        public static let firstErrorCode = 300
        public static let networkErrorCode = -1009
        public static let emptyRessponseBodyCode = 204
    }

    // MARK: - Fileds

    public var httpResponse: HTTPURLResponse?
    public let statusCode: Int
    public internal(set) var isNotModified: Bool
    public internal(set) var isConnectionFailed: Bool
    public var result: ResponseResult<Any>
    public internal(set) var errorMapper: ErrorMapperAdapter?

    // MARK: - Initializers

    /// For creating Cached responses
    internal override init() {
        self.statusCode = Const.succesCode
        self.isNotModified = true
        self.isConnectionFailed = false
        self.result = .failure(BaseCacheError.cantFindInCache)
        super.init()
    }

    init(dataResponse: DefaultDataResponse?, dataResult: ResponseResult<Data?>, errorMapper: ErrorMapperAdapter? = nil) {
        self.httpResponse = dataResponse?.response
        let statusCode = self.httpResponse?.statusCode ?? 0
        self.statusCode = statusCode
        self.isNotModified = self.statusCode == Const.notModifiedCode
        self.isConnectionFailed = false
        self.errorMapper = errorMapper
        self.result = .failure(BaseServerError.undefind)
        super.init()
        if (dataResponse?.error as NSError?)?.code == Const.networkErrorCode {
            self.result = .failure(BaseServerError.networkError)
            self.isConnectionFailed = true
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

private extension BaseCoreServerResponse {

    func trySerializeToJson(data: Data?) -> Any? {
        return try? JSONSerialization.jsonObject(with: data ?? Data(), options: .allowFragments)
    }

    func parseError(data: Data?) -> LocalizedError {
        guard let error = self.trySerializeToJson(data: data) else {
            return BaseServerError.badJsonFormat
        }
        guard let customError = self.errorMapper?.map(json: error, httpCode: self.statusCode) else {
            return BaseServerError.undefind
        }

        return customError
    }
}
