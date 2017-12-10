//
//  UserEntity.swift
//  Example
//
//  Created by Александр Кравченков on 10.12.2017.
//  Copyright © 2017 Кравченков Александр. All rights reserved.
//

import Foundation

public class UserMiniEntity: Codable {
    public let id: Int
    public let name: String
    public let username: String
    public let email: String
}
