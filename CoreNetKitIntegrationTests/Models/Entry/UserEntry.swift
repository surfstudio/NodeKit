//
//  UserEntry.swift
//  CoreNetKitIntegrationTests
//
//  Created by Александр Кравченков on 01/02/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

@testable
import CoreNetKit

public struct UserEntry: Codable, RawMappable {
    
    public typealias Raw = Json

    public var id: String
    public var firstName: String
    public var lastName: String
}
