//
//  Method+Alamofire.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 23/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Alamofire

/// Содержит конвертирование NodeKit.Method в Alamofire.HTTPMethod
extension NodeKit.Method {

    /// Содержит конвертирование CoreNetKit.Method в Alamofire.HTTPMethod
    public var http: HTTPMethod {
        switch self {
        case .connect:
            return .connect
        case .head:
            return .head
        case .options:
            return .options
        case .patch:
            return .patch
        case .trace:
            return .trace
        case .get:
            return .get
        case .post:
            return .post
        case .put:
            return .put
        case .delete:
            return .delete
        }
    }
}
