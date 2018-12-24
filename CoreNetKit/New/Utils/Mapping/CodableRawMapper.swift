//
//  CodableRawMapper.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 24/12/2018.
//  Copyright © 2018 Кравченков Александр. All rights reserved.
//

import Foundation

public enum RawMappableCodableError: Error {
    case cantMapObjectToRaw
}

public extension RawMappable where Self: Encodable, Raw == [String: Any] {
    func toRaw() throws -> Raw {
        let encoder = JSONEncoder()
        let data = try encoder.encode(self)
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        guard let dict = jsonObject as? [String: Any] else {
            throw RawMappableCodableError.cantMapObjectToRaw
        }
        return dict
    }
}

public extension RawMappable where Self: Decodable, Raw == [String: Any] {
    static func toModel(from raw: Raw) throws -> Self {
        let decoder = JSONDecoder()
        let data = try JSONSerialization.data(withJSONObject: raw, options: .prettyPrinted)
        return try decoder.decode(Self.self, from: data)
    }
}
