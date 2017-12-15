//
//  CoreServerResponse.swift
//  CoreNetKit
//
//  Created by Alexander Kravchenkov on 15.12.17.
//  Copyright © 2017 Кравченков Александр. All rights reserved.
//

import Foundation

public protocol CoreServerResponse {
    var isNotModified: Bool { get }
    var statusCode: Int { get }
    var isConnectionFailed: Bool { get }
    
    var result: ResponseResult<Any> { get set }
    var httpResponse: HTTPURLResponse? { get set }
}
