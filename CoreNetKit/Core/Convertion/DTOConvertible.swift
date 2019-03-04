//
//  DTOConvertible.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 18/12/2018.
//  Copyright © 2018 Кравченков Александр. All rights reserved.
//

import Foundation

public protocol DTOConvertible {

    associatedtype DTO: RawMappable

    static func toModel(from: DTO) throws -> Self
    func toDTO() throws -> DTO
}
