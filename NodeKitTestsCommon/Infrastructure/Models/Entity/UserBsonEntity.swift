//
//  UserBsonEntity.swift
//  IntegrationTests
//
//  Created by Vladislav Krupenko on 03.04.2020.
//  Copyright © 2020 Кравченков Александр. All rights reserved.
//

import Foundation

@testable
import NodeKit
import BSON

struct UserBsonEntity {
    let id: String
    let firstName: String
    let lastName: String
}

extension UserBsonEntity: DTOConvertible {

    typealias DTO = Document

    public static func from(dto model: Document) throws -> UserBsonEntity {
        let id = (model["id"] as? String) ?? ""
        let firstName = (model["firstname"] as? String) ?? ""
        let lastName = (model["lastname"] as? String) ?? ""
        return .init(id: id, firstName: firstName, lastName: lastName)
    }

    func toDTO() throws -> Document {
        let document: Document = [
            "id": id,
            "firstname": firstName,
            "lastname": lastName
        ]
        return document
    }

}

