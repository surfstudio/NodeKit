//
//  BaseRequest.swift
//  Sample
//
//  Created by Alexander Kravchenkov on 06.07.17.
//  Copyright © 2017 Alexander Kravchenkov. All rights reserved.
//

import Foundation
import Alamofire

/// Обертка над ResponseResult<Value> для того, чтобы не тянуть либу на другие слои
public enum BaseResult<Value> {

    /// Значение, полученное из запроса. Bool - флаг,показывающий было ли значение взято из кеша
    case value(Value, Bool)
    /// Ошибка, полученная из запроса
    case error(Error)

    /// Создает объект из ResponseResult
    ///
    /// - Parameter afResult: результат выполнения запроса
    init(with baseResult: ResponseResult<Value>) {
        switch baseResult {
        case .success(let value, let isCached):
            self = .value(value, isCached)
        case .failure(let error):
            self = .error(error)
        }
    }
}

public extension BaseResult {
    var value: (value: Value, fromCahce: Bool)? {
        guard case .value(let val, let fromCache) = self else {
            return nil
        }
        return (val, fromCache)
    }
    var error: Error? {
        guard case .error(let err) = self else {
            return nil
        }
        return err
    }
}
