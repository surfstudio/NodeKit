//
//  ExampleService.swift
//  NetworkLayer
//
//  Created by Александр Кравченков on 14.10.2017.
//  Copyright © 2017 Кравченков Александр. All rights reserved.
//

import Foundation

public class ExampleService {
    public static func send() -> RequestContext<Void> {
        let req = ExampleRequest()
        let context = RequestContext<Void>()
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
}
