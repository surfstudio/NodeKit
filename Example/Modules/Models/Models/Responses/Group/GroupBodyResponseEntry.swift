//
//  GroupBodyResponseEntry.swift
//
//  Created by Andrei Frolov on 11.04.24.
//

import NodeKit

public struct GroupBodyResponseEntry {
    let text: String
    let image: String
}

extension GroupBodyResponseEntry: Codable, RawMappable {
    public typealias Raw = Json
}
