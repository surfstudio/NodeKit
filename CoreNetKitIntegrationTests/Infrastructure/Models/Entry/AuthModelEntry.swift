//
//  AuthEntry.swift
//  CoreNetKitIntegrationTests
//
//  Created by Александр Кравченков on 04/02/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

@testable
import CoreNetKit

public struct AuthModelEntry {
    public let type: String
    public let secret: String
}

extension AuthModelEntry: Codable { }

extension AuthModelEntry: RawMappable {
    public typealias Raw = Json
}
