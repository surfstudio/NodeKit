//
//  TokenProvider.swift
//  CoreNetKit
//
//  Created by Alexander Kravchenkov on 05.04.2018.
//  Copyright © 2018 Кравченков Александр. All rights reserved.
//

import Foundation

public protocol TokenProvider {

    /// Authorization token header field name
    var headerFieldName: String { get }

    func getToken() -> String?

}

extension TokenProvider {
    public var headerFieldName: String {
        return "Authorization"
    }
}

public struct DefaultTokenProvider: TokenProvider {

    private let tokenString: String

    public func getToken() -> String? {
        return self.tokenString
    }
}
