//
//  ExampleRequest.swift
//  NetworkLayer
//
//  Created by Александр Кравченков on 14.10.2017.
//  Copyright © 2017 Кравченков Александр. All rights reserved.
//

import Foundation

class ExampleRequest: BaseServerRequest<Void> {
    override func handle(serverResponse: ServerResponse, completion: RequestCompletion) {
        print("Example Reuest handler called")
        completion(.success((), false))
    }

    override func createAsyncServerRequest() -> ServerRequest {
        return ServerRequest(method: .get, relativeUrl: "", baseUrl: "https://github.com", parameters: .simpleParams(nil))
    }

    deinit {
        print("ExampleRequest DEINIT CALLED")
    }

}
