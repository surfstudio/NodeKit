//
//  ResponseResult.swift
//  CoreNetKit
//
//  Created by Alexander Kravchenkov on 15.12.17.
//  Copyright © 2017 Кравченков Александр. All rights reserved.
//

import Foundation

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
