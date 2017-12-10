//
//  LoginRequest.swift
//  Example
//
//  Created by Александр Кравченков on 10.12.2017.
//  Copyright © 2017 Кравченков Александр. All rights reserved.
//

import Foundation
import CoreNetKit

class GetUserListRequest: BaseServerRequest<UserMiniEntity> {

    override func createAsyncServerRequest() -> CoreServerRequest {
        return CoreServerRequest(method: .get, relativeUrl: ExampleUrls.users, baseUrl: ExampleUrls.baseUrl, parameters: .simpleParams(nil), cacheAdapter: UrlCacheAdapter())
    }

    override func handle(serverResponse: CoreServerResponse, completion: (ResponseResult<UserMiniEntity>) -> Void) {
        switch serverResponse {
        case <#pattern#>:
            <#code#>
        default:
            <#code#>
        }
    }
}
