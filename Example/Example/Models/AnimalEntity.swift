//
//  AnimalEntity.swift
//  Example
//
//  Created by Alexander Kravchenkov on 06.04.2018.
//  Copyright © 2018 Кравченков Александр. All rights reserved.
//

import Foundation

public struct AnimalEntity {
    var name: String
    var image: String

    init?(json: [String: Any]) {
        guard let name = json["name"] as? String, let image = json["img"] as? String else {
            return nil
        }

        self.name = name
        self.image = image
    }
}
