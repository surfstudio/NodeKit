//
//  SyncServerResponse.swift
//  Sample
//
//  Created by Alexander Kravchenkov on 06.07.17.
//  Copyright © 2017 Alexander Kravchenkov. All rights reserved.
//

import Foundation
import Alamofire

class SyncServerRequest: ServerRequest {

    override func perform(with completion: @escaping (ServerResponse) -> Void) {
        let headers = super.createHeaders()
        let manager = ServerRequestsManager.shared.manager
        let semph = DispatchSemaphore(value: 0)
        var response: ServerResponse!

        let performRequest = { (request: DataRequest) -> Void in
            request.response(queue: DispatchQueue.global(qos: .default)) { afResponse in
                response = ServerResponse(dataResponse: afResponse, dataResult: .success(afResponse.data, false))

                switch self.cachePolicy {
                case .serverOnly:
                    break
                case .cacheOnly:
                    let response = ServerResponse(dataResponse: afResponse, dataResult: .success(afResponse.data, false))
                    if let cachedResponse = self.extractCachedUrlResponse(), let resultResponse = cachedResponse.response as? HTTPURLResponse {
                        response.httpResponse = resultResponse
                        response.result = { () -> ResponseResult<Any> in
                            do {
                                let object = try JSONSerialization.jsonObject(with: cachedResponse.data, options: .allowFragments)
                                return .success(object, true)
                            } catch {
                                return .failure(BaseCacheError.cantLoadFromCache)
                            }
                        }()
                        if let data = response.result.value as? Data, let urlResponse = afResponse.response {
                            self.store(cachedUrlResponse: CachedURLResponse(response: urlResponse, data: data), for: request.request)
                        }
                    } else {
                        response.result = .failure(BaseCacheError.cantFindInCache)
                    }
                case .firstCacheThenRefreshFromServer:
                    preconditionFailure("This request cant perform with firstCacheThenRefreshFromServer cache policy")
                case .serverIfFailReadFromCahce:
                    break
                    // TODO: create for sync
                }

                self.log(afResponse)
                semph.signal()
            }
        }

        switch parameters {
        case .simpleParams(let params):
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
            performRequest(request)
        case .multipartParams(let params):
            manager.upload(multipartFormData: { (multipartFormData) in
                for data in params {
                    multipartFormData.append(data.data, withName: data.name, fileName: data.fileName, mimeType: data.fileName)
                }
            }, to: super.url, method: super.method.alamofire, headers: headers, encodingCompletion: { (encodingResult) in
                switch encodingResult {
                case let .success(request: uploadRequest, streamingFromDisk: _, streamFileURL: _):
                    performRequest(uploadRequest)
                case let .failure(error):
                    response = ServerResponse(dataResponse: nil, dataResult: .failure(error))
                }
                semph.signal()
            })
        }

        _ = semph.wait(timeout: DispatchTime.distantFuture)

        completion(response)
    }
}
