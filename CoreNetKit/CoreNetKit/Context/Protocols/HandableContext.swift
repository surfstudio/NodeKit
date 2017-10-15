//
//  HandableContext.swift
//  NetworkLayer
//
//  Created by Александр Кравченков on 14.10.2017.
//  Copyright © 2017 Кравченков Александр. All rights reserved.
//

import Foundation

/// 'ActionableContext', provided custom handling that may convert request result type to needed type.
public protocol HandableRequestContext: ActionableContext {

    associatedtype RequestResultType

    init(request: BaseServerRequest<RequestResultType>, handler: @escaping (ResponseResult<RequestResultType>) -> ResponseResult<ResultType>)
}
