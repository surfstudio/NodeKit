//
//  RawMappable.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 18/12/2018.
//  Copyright © 2018 Кравченков Александр. All rights reserved.
//

import Foundation

public protocol RawMappable {

    associatedtype Raw

    func toRaw() throws -> Raw

    static func toModel(from: Raw) throws -> Self
}
