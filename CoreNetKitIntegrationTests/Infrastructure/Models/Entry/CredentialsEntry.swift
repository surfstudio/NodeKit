//
//  CredentialsEntry.swift
//  CoreNetKitIntegrationTests
//
//  Created by Александр Кравченков on 04/02/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

@testable
import CoreNetKit

public struct CredentialsEntry {
    public let accessToken: String
    public let refreshToken: String
}

extension CredentialsEntry: Codable {}

extension CredentialsEntry: RawMappable {
    public typealias Raw = Json
}
