//
//  Countable.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 15.10.2017.
//  Copyright © 2017 Кравченков Александр. All rights reserved.
//

import Foundation

public protocol Countable {

    var itemsCount: Int { get }

    var itemsIsEmpty: Bool { get }
}

extension Array: Countable {

    public var itemsCount: Int {
        return self.count
    }

    public var itemsIsEmpty: Bool {
        return self.isEmpty
    }
}
