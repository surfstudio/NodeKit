//
//  GroupFooterResponseEntry.swift
//
//  Created by Andrei Frolov on 11.04.24.
//

import NodeKit

public struct GroupFooterResponseEntry {
    let text: String
    let image: String
}

extension GroupFooterResponseEntry: Codable, RawMappable {
    public typealias Raw = Json
}
