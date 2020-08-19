//
//  AuthModel.swift
//  CoreNetKitIntegrationTests
//
//  Created by Александр Кравченков on 04/02/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

@testable
import NodeKit

public struct AuthModel {
    public let type: String
    public let secret: String
}

extension AuthModel: DTOConvertible {

    public typealias DTO = AuthModelEntry

    public static func from(dto: AuthModelEntry) throws -> AuthModel {
        return AuthModel(type: dto.type, secret: dto.secret)
    }

    public func toDTO() throws -> AuthModelEntry {
        return AuthModelEntry(type: self.type, secret: self.secret)
    }
}
