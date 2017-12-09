//
//  HandleRequestContext.swift
//  NetworkLayer
//
//  Created by Александр Кравченков on 14.10.2017.
//  Copyright © 2017 Кравченков Александр. All rights reserved.
//

import Foundation

/// Context that incapsulate request handle
/// It may used for automatic convertion response type to awaiting type
public class HandleRequestContext<RequestModel, ResultModel>: HandableRequestContext {

    // MARK: - Typealiases
					
    public typealias ResultType = ResultModel
    public typealias RequestType = RequestModel
    public typealias CompletedClosure = (ResultModel) -> Void
    public typealias HandlerClosure = (ResponseResult<RequestModel>) -> ResponseResult<ResultModel>
    public typealias ErrorClosure = (Error) -> Void

    // MARK: - Private fields

    private var completedClosure: CompletedClosure?
    private var errorClosure: ErrorClosure?
    
    private let request: BaseServerRequest<RequestModel>
    private let handler: HandlerClosure

    // MARK: - Initializers / Deinitializers

    public required init(request: BaseServerRequest<RequestModel>, handler: @escaping HandlerClosure) {
        self.request = request
        self.handler = handler
    }

    #if DEBUG

    deinit {
        print("ActiveRequestContext DEINIT")
    }

    #endif

    // MARK: - Context methods

    public func onCompleted(_ closure: @escaping CompletedClosure) {
        self.completedClosure = closure
    }

    public func onError(_ closure: @escaping ErrorClosure) {
        self.errorClosure = closure
    }

    public func perform() {
        self.request.performAsync { result in
            let converted = self.handler(result)
            switch converted {
            case .failure(let error):
                self.errorClosure?(error)
            case .success(let value, _):
                self.completedClosure?(value)
            }
        }
    }
}
