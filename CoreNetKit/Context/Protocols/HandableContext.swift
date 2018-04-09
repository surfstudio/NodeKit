//
//  HandableContext.swift
//  NetworkLayer
//
//  Created by Александр Кравченков on 14.10.2017.
//  Copyright © 2017 Кравченков Александр. All rights reserved.
//

import Foundation

/// 'ActionableContext' that conrains handler for server response.
/// It means that after server response this context apply closure `(ResponseResult<RequestResultType>) -> ResponseResult<ResultType>` to response model
///
/// _This context couple of Core network layer implementation_
public protocol HandableRequestContextProtocol: ActionableContextProtocol {

    associatedtype RequestResultType

    init(request: BaseServerRequest<RequestResultType>, handler: @escaping (ResponseResult<RequestResultType>) -> ResponseResult<ResultType>)
}
