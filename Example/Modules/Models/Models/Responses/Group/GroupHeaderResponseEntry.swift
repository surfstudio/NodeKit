//
//  GroupHeaderResponseEntry.swift
//
//  Created by Andrei Frolov on 11.04.24.
//

import NodeKit

public struct GroupHeaderResponseEntry {
    let text: String
    let image: String
}

extension GroupHeaderResponseEntry: Codable, RawMappable {
    public typealias Raw = Json
}
