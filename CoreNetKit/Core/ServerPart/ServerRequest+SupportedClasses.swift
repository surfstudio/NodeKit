//
//  ServerRequest+SupportedClasses.swift
//  Sample
//
//  Created by Alexander Kravchenkov on 07.07.17.
//  Copyright © 2017 Alexander Kravchenkov. All rights reserved.
//

import Foundation
import Alamofire

public enum ServerRequestParameter {
    case simpleParams([String: Any]?)
    case multipartParams([MultipartData])
}

/// Кастомный результат ответа сервера
public enum ResponseResult<Value> {
    /// Value - значение, полученное в результате, Bool - флаг, говорящий о том, что данное значение получено из кэша
    case success(Value, Bool)
    /// Ошибка, полученная в ходе запроса
    case failure(Error)

    /// Возвращает значение. Если его нету, тогда nil
    var value: Value? {
        switch self {
        case .success(let result, _):
            return result
        case .failure:
            return nil
        }
    }

    /// Возвращает ошибку. Если ее нету, тогда nil
    var error: Error? {
        switch self {
        case .success:
            return nil
        case .failure(let result):
            return result
        }
    }

    /// Возвращает флаг, говорящий, был ли ответ взят из кеша.
    var isCached: Bool {
        switch self {
        case .success(_, let cachedFlag):
            return cachedFlag
        case .failure:
            return false
        }
    }
}

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

public enum CachePolicy {
    case serverOnly
    case cacheOnly
    case firstCacheThenRefreshFromServer
    case serverIfFailReadFromCahce
}
