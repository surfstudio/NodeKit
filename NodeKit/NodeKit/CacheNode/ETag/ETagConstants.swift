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

    /// There should be the eTag token under **this** key in the **response** headers.
    ///
    /// - SeeAlso:
    ///     - [AppleDeveloper](https://developer.apple.com/documentation/foundation/httpurlresponse/1417930-allheaderfields)
    ///     - [RFC-7232](https://tools.ietf.org/html/rfc7232#section-2.3)
    public static var eTagResponseHeaderKey: String {
        return "Etag"
    }

    /// /// There should be the eTag token under **this** key in the **response** headers.
    ///
    /// - SeeAlso: [RFC-7232](https://tools.ietf.org/html/rfc7232#section-3.2)
    ///
    public static var eTagRequestHeaderKey: String {
        return "If-None-Match"
    }
}
