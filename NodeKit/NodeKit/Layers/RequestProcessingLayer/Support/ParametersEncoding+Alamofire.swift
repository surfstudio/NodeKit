//
//  ParametersEncoding+Alamofire.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 23/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

/// Содержит конвертирование NodeKit.ParametersEncoding в Alamofire.ParameterEncoding
extension NodeKit.ParametersEncoding {

    /// Содержит конвертирование CoreNetKit.ParametersEncoding в Alamofire.ParameterEncoding
    public var raw: ParameterEncoding {
        switch self {
        case .json:
            return JSONEncoding()
        case .formURL:
            return URLEncoding.default
        case .urlQuery:
            return URLEncoding.queryString
        }
    }

}
