//
//  User.swift
//  CoreNetKitIntegrationTests
//
//  Created by Александр Кравченков on 28/01/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

@testable
import CoreNetKit

public struct User: DTOConvertible {

    public typealias DTO = UserEntry

    public var id: String
    public var firstName: String
    public var lastName: String

    public static func from(dto: UserEntry) throws -> User {
        return User(id: dto.id, firstName: dto.firstName, lastName: dto.lastName)
    }

    public func toDTO() throws -> UserEntry {
        return UserEntry(id: self.id, firstName: self.firstName, lastName: self.lastName)
    }
}
