//
//  ETagConstants.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 17/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// Содержит константы для работы с eTag
/// Эти кнстанты описаны в соответствии с RFC и AppleDeveloper
public enum ETagConstants {

    /// В хедерах **ответа** от сервера под **этим** ключем должен лежать eTag-токен
    ///
    /// - SeeAlso:
    ///     - [AppleDeveloper](https://developer.apple.com/documentation/foundation/httpurlresponse/1417930-allheaderfields)
    ///     - [RFC-7232](https://tools.ietf.org/html/rfc7232#section-2.3)
    public static var eTagResponseHeaderKey: String {
        return "Etag"
    }

    /// В хедерах **запроса** к серверу под этим ключем должен лежать eTag-токен
    ///
    /// - SeeAlso: [RFC-7232](https://tools.ietf.org/html/rfc7232#section-3.2)
    ///
    public static var eTagRequestHeaderKey: String {
        return "If-None-Match"
    }
}
