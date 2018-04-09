//
//  NetworkLayerBaseErrors.swift
//  Sample
//
//  Created by Alexander Kravchenkov on 06.07.17.
//  Copyright © 2017 Alexander Kravchenkov. All rights reserved.
//

import Foundation

public enum BaseServerError: LocalizedError {
    case internalServerError
    case badJsonFormat
    case networkError
    case undefind
    case cantMapping
    case unauthorized
}

public enum BaseCacheError: LocalizedError {
    case cantFindInCache
    case cantLoadFromCache
}
