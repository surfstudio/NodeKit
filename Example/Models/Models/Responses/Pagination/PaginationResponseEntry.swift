//
//  PaginationResponseEntry.swift
//
//  Created by Andrei Frolov on 11.04.24.
//

import NodeKit

public struct PaginationResponseEntry {
    let name: String
    let image: String
}

extension PaginationResponseEntry: Codable, RawMappable {
    public typealias Raw = Json
}
