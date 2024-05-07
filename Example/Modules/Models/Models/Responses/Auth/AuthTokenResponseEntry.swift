//
//  AuthTokenResponseEntry.swift
//
//  Created by Andrei Frolov on 11.04.24.
//

import NodeKit

public struct AuthTokenResponseEntry {
    let accessToken: String
    let refreshToken: String
}

extension AuthTokenResponseEntry: Codable, RawMappable {
    public typealias Raw = Json
}
