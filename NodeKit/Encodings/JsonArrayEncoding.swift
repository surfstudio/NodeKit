//
//  JsonArrayEncoding.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 17/04/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation
import Alamofire

open class JsonArrayEncoding: ParameterEncoding {

    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var urlRequest = try urlRequest.asURLRequest()
        guard let parameters = parameters else { return urlRequest }

        var json: Any = parameters

        if let array = parameters[MappingUtils.arrayJsonKey] {
            json = array
        }

        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])

            if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }

            urlRequest.httpBody = data
        } catch {
            throw AFError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))
        }

        return urlRequest

        
    }
}
