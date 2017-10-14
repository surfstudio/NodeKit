//
//  Serverrequest.swift
//  Sample
//
//  Created by Alexander Kravchenkov on 06.07.17.
//  Copyright © 2017 Alexander Kravchenkov. All rights reserved.
//

import Foundation
import Alamofire

@objc
class ServerRequest: NSObject {

    typealias PerformedRequest = (DataRequest) -> Void
    typealias Completion = (ServerResponse) -> Void

    enum Method {
        case get
        case post
        case put
        case delete

        var alamofire: Alamofire.HTTPMethod {
            switch self {
            case .get: return .get
            case .post: return .post
            case .put: return .put
            case .delete: return .delete
            }
        }
    }

    enum Encoding {
        case defaultJson
        case defaultUrl
        case queryStringUrl

        var alamofire: Alamofire.ParameterEncoding {
            switch self {
            case .defaultJson:
                return JSONEncoding.default
            case .defaultUrl:
                return URLEncoding.default
            case .queryStringUrl:
                return URLEncoding.queryString
            }
        }
    }

    /// Метод API
    let path: String
    /// Результирующий URL запроса - включает baseUrl и path
    let url: URL
    /// Метод (get, post, delete...)
    let method: Method
    /// Токен для хедера
    let token: String?
    /// Хидеры запроса
    let headers: HTTPHeaders?
    /// Параметры запроса
    var parameters: ServerRequestParameter
    /// serverOnly by default
    var cachePolicy: CachePolicy

    let customEncoding: Encoding?

    let errorMapper: ErrorMapperAdapter?

    fileprivate var currentRequest: DataRequest? = nil

    init(method: Method, relativeUrl: String, baseUrl: String, token: String? = nil, headers: HTTPHeaders? = nil, parameters: ServerRequestParameter, customEncoding: Encoding? = nil, errorMapper: ErrorMapperAdapter? = nil) {
        self.method = method
        self.token = token
        self.headers = headers
        self.path = relativeUrl
        self.url = (URL(string: baseUrl)?.appendingPathComponent(self.path))!
        self.parameters = parameters
        self.cachePolicy = .serverIfFailReadFromCahce
        self.customEncoding = customEncoding
        self.errorMapper = errorMapper
        super.init()
    }

    func perform(with completion: @escaping (ServerResponse) -> Void) {

        let requests = self.createRequestWithPolicy(with: completion)

        switch self.parameters {
        case .simpleParams(let params):
            let request = self.createSingleParamRequest(params)
            requests.forEach({ $0(request) })
        case .multipartParams(let params):
            self.createMultipartParamRequest(params, with: { result in
                switch result {
                case .succes(let request):
                    requests.forEach({ $0(request) })
                case .failure(let resp):
                    completion(resp)
                }
            })
        }
    }

    func createRequestWithPolicy(with completion: @escaping Completion) -> [PerformedRequest] {
        switch self.cachePolicy {
        case .cacheOnly:
            return [self.readFromCache(completion: completion)]
        case .serverOnly, .serverIfFailReadFromCahce:
            return [self.sendRequest(completion: completion)]
        case .firstCacheThenRefreshFromServer:
            let cacheRequest = self.readFromCache(completion: completion)
            let serverRequest = self.sendRequest(completion: completion)

            return [cacheRequest, serverRequest]
        }
    }

    /// Этот метод используется для отмены текущего запроса
    func cancel() {
        currentRequest?.cancel()
    }

    // MARK: - Helps

    /// Возвращает хедеры, которые необходимы для данного запроса.
    func createHeaders() -> HTTPHeaders {
        var headers: HTTPHeaders = self.headers ?? [:]
        if let tokenString = token {
            headers["Authorization"] = tokenString
        }
        headers ["Content-Type"] = "Application/json"
        return headers
    }
}

// MARK: - Work witch URLCache

extension ServerRequest {

    /// Извлекает из кэш из URLCache для конкретного запроса
    func extractCachedUrlResponse() -> CachedURLResponse? {
        guard let urlRequest = self.currentRequest?.request else {
            return nil
        }

        if let response = URLCache.shared.cachedResponse(for: urlRequest) {
            return response
        }
        return nil
    }

    func extractCachedUrlResponse(request: URLRequest?) -> CachedURLResponse? {
        guard let urlRequest = request else {
            return nil
        }

        if let response = URLCache.shared.cachedResponse(for: urlRequest) {
            return response
        }
        return nil
    }

    /// Сохраняет запрос в кэш
    func store(cachedUrlResponse: CachedURLResponse, for request: URLRequest?) {
        guard let urlRequest = request else {
            return
        }

        URLCache.shared.storeCachedResponse(cachedUrlResponse, for: urlRequest)
    }
}

extension ServerRequest {

    enum MultipartRequestCompletion {
        case succes(DataRequest)
        case failure(ServerResponse)
    }

    func createSingleParamRequest(_ params: [String: Any]?) -> DataRequest {

        let headers = self.createHeaders()
        let manager = ServerRequestsManager.shared.manager

        let paramEncoding = {() -> ParameterEncoding in
            if let custom = self.customEncoding {
                return custom.alamofire
            }
            return self.method.alamofire == .get ? URLEncoding.default : JSONEncoding.default
        }()

        let request = manager.request(
            url,
            method: method.alamofire,
            parameters: params,
            encoding: paramEncoding,
            headers: headers
        )

        return request
    }

    func createMultipartParamRequest(_ params: [MultipartData], with completion: @escaping (MultipartRequestCompletion) -> Void) {

        let headers = self.createHeaders()
        let manager = ServerRequestsManager.shared.manager

        manager.upload(multipartFormData: { (multipartFormData) in
            for data in params {
                multipartFormData.append(data.data, withName: data.name, fileName: data.fileName, mimeType: data.fileName)
            }
        }, to: self.url, method: self.method.alamofire, headers: headers, encodingCompletion: { (encodingResult) in
            switch encodingResult {
            case let .success(request: uploadRequest, streamingFromDisk: _, streamFileURL: _):
                completion(.succes(uploadRequest))
            case let .failure(error):
                let response = ServerResponse(dataResponse: nil, dataResult: .failure(error), errorMapper: self.errorMapper)
                completion(.failure(response))
            }
        })
    }

    func createDataRequest() {

    }
}

// MARK: - Requests

extension ServerRequest {

    func sendRequest(completion: @escaping Completion) -> PerformedRequest {
        let performRequest = { (request: DataRequest) -> Void in
            self.currentRequest = request
            request.response { afResponse in
                self.log(afResponse)
                var response = ServerResponse(dataResponse: afResponse, dataResult: .success(afResponse.data, false), errorMapper: self.errorMapper)

                if (response.notModified || response.connectionFailed) && self.cachePolicy == .serverIfFailReadFromCahce {
                    response = self.readCache(with: request.request, response: response)
                }

                if response.result.value != nil, let urlResponse = afResponse.response, let data = afResponse.data, self.cachePolicy != .serverOnly {
                    self.store(cachedUrlResponse: CachedURLResponse(response: urlResponse, data: data, storagePolicy: .allowed), for: request.request)
                }

                completion(response)

            }
        }
        return performRequest
    }

    func readFromCache(completion: @escaping Completion) -> PerformedRequest {
        let performRequest = { (request: DataRequest) -> Void in
            completion(self.readCache(with: request.request))
        }
        return performRequest
    }

    func readCache(with request: URLRequest?, response: ServerResponse? = nil) -> ServerResponse {

        let result = response ?? ServerResponse()

        if let cachedResponse = self.extractCachedUrlResponse(request: request),
            let resultResponse = cachedResponse.response as? HTTPURLResponse {
            result.httpResponse = resultResponse
            result.result = { () -> ResponseResult<Any> in
                do {
                    let object = try JSONSerialization.jsonObject(with: cachedResponse.data, options: .allowFragments)
                    return .success(object, true)
                } catch {
                    return .failure(BaseCacheError.cantLoadFromCache)
                }
            }()
        }
        return result
    }
}

// MARK: - Supported methods

extension ServerRequest {
    func log(_ afResponse: DefaultDataResponse) {
        #if DEBUG
            let url: String = afResponse.request?.url?.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let type: String = afResponse.request?.httpMethod ?? ""
            let headers: String = afResponse.request?.allHTTPHeaderFields?.description ?? ""
            let body = String(data: afResponse.request?.httpBody ?? Data(), encoding: String.Encoding.utf8) ?? ""
            let statusCode: String = "\(afResponse.response?.statusCode ?? 0)"
            let reponseHeaders: String = afResponse.response?.allHeaderFields.description ?? ""

            var responseBody: String = ""

            if let data = afResponse.data {
                responseBody = "\(String(data: data, encoding: .utf8) ?? "nil")"
            }
            debugPrint("URL: \(url)")
            debugPrint("REQUEST: \(type)")
            debugPrint("HEADERS: \(headers)")
            NSLog("BODY: %@", body)
            debugPrint("RESPONSE: \(statusCode)")
            debugPrint("HEADERS: \(reponseHeaders)")
            NSLog("BODY: %@", responseBody)
            debugPrint("TIMELINE: \(afResponse.timeline)")
            debugPrint("DiskCache: \(URLCache.shared.currentDiskUsage) of \(URLCache.shared.diskCapacity)")
            debugPrint("MemoryCache: \(URLCache.shared.currentMemoryUsage) of \(URLCache.shared.memoryCapacity)")
        #else
        #endif
    }
}
