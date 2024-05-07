//
//  AuthRequestEntry.swift
//
//  Created by Andrei Frolov on 11.04.24.
//

import NodeKit

public struct AuthRequestEntry: Codable {
    let email: String
    let password: String
}

extension AuthRequestEntry: RawEncodable {
    public typealias Raw = Json
}
