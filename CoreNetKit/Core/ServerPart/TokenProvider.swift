//
//  TokenProvider.swift
//  CoreNetKit
//
//  Created by Alexander Kravchenkov on 05.04.2018.
//  Copyright © 2018 Кравченков Александр. All rights reserved.
//

import Foundation

public protocol TokenProvider {

    func getToken() -> String?
}

public struct DefaultTokenProvider: TokenProvider {

    private let tokenString: String

    public func getToken() -> String? {
        return self.tokenString
    }
}
