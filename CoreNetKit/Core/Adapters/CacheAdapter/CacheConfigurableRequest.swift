//
//  CacheConfigurableRequest.swift
//  CoreNetKit
//
//  Created by Serge Nanaev on 27.04.2018.
//  Copyright © 2017 Кравченков Александр. All rights reserved.
//

import Foundation

public protocol CacheConfigurableRequest {
    var url: URL? { get }
    var allHTTPHeaderFields: [String : String]? { get set }
}

extension URLRequest: CacheConfigurableRequest {}
