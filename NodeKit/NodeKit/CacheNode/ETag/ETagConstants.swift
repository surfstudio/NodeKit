//
//  ETagConstants.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 17/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// Constants for working with eTags
/// These constants are described in accordance with RFC and AppleDeveloper.
public enum ETagConstants {

    /// In the **response** headers, the eTag token should be placed under **this** key.
    ///
    /// - SeeAlso:
    ///     - [AppleDeveloper](https://developer.apple.com/documentation/foundation/httpurlresponse/1417930-allheaderfields)
    ///     - [RFC-7232](https://tools.ietf.org/html/rfc7232#section-2.3)
    public static var eTagResponseHeaderKey: String {
        return "Etag"
    }

    /// In the **request** headers, the eTag token should be placed under **this** key.
    ///
    /// - SeeAlso: [RFC-7232](https://tools.ietf.org/html/rfc7232#section-3.2)
    ///
    public static var eTagRequestHeaderKey: String {
        return "If-None-Match"
    }
}
