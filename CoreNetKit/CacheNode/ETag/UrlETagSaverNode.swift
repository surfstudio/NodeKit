//
//  eTagSaverNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 04/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

public enum ETagConstants {

    // https://developer.apple.com/documentation/foundation/httpurlresponse/1417930-allheaderfields
    // https://tools.ietf.org/html/rfc7232#section-2.3
    public static var eTagResponseHeaderKey: String {
        return "Etag"
    }

    // https://tools.ietf.org/html/rfc7232#section-3.2
    public static var eTagRequestHeaderKey: String {
        return "If-None-Match"
    }
}

extension UserDefaults {
    static var etagStorage = UserDefaults(suiteName: "\(self.self)")
}

open class UrlETagSaverNode: ResponsePostprocessorLayerNode {

    public var next: ResponsePostprocessorLayerNode?
    public var eTagHeaderKey: String

    public init(next: ResponsePostprocessorLayerNode?, eTagHeaderKey: String = ETagConstants.eTagResponseHeaderKey) {
        self.next = next
        self.eTagHeaderKey = eTagHeaderKey
    }

    open override func process(_ data: UrlProcessedResponse) -> Observer<Void> {
        guard let tag = data.response.allHeaderFields[self.eTagHeaderKey] as? String,
            let url = data.request.url else {
            return .emit(data: ())
        }

        UserDefaults.etagStorage?.set(tag, forKey: url.absoluteString)

        return next?.process(data) ?? .emit(data: ())
    }
}
