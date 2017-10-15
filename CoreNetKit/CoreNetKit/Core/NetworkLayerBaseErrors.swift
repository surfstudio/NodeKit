//
//  NetworkLayerBaseErrors.swift
//  Sample
//
//  Created by Alexander Kravchenkov on 06.07.17.
//  Copyright © 2017 Alexander Kravchenkov. All rights reserved.
//

import Foundation

enum BaseServerError: LocalizedError {
    case internalServerError
    case badJsonFormat
    case networkError
    case undefind
    case cantMapping
}

enum BaseCacheError: LocalizedError {
    case cantFindInCache
    case cantLoadFromCache
}
