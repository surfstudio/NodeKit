//
//  ExampleService.swift
//  NetworkLayer
//
//  Created by Александр Кравченков on 14.10.2017.
//  Copyright © 2017 Кравченков Александр. All rights reserved.
//

import Foundation

public class ExampleService {
    public static func send() -> PassiveRequestContext<Void> {
        let req = ExampleRequest()
        let context = PassiveRequestContext<Void>()
        req.performAsync { result in
            switch result {
            case .failure(let error):
                context.performError(error: error)
            case .success(let value, _):
                context.performComplete(result: value)
            }
        }
        return context
    }

    public static func activeSend() -> ActiveRequestContext<Void> {
        let req = ExampleRequest()
        let context = ActiveRequestContext(request: req)
        return context
    }
}
