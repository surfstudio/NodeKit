//
//  PaginationRequestEntry.swift
//
//  Created by Andrei Frolov on 11.04.24.
//

import NodeKit

public struct PaginationRequestEntry {
    let index: Int
    let pageSize: Int
}

extension PaginationRequestEntry: Codable, RawEncodable {
    public typealias Raw = Json
}
