//
//  Node.swift
//  CoreNetKitWithExample
//
//  Created by Александр Кравченков on 27/11/2018.
//  Copyright © 2018 Александр Кравченков. All rights reserved.
//

import Foundation

/// Protocol describing any node or chain of nodes.
/// Necessary for combining all types of nodes and adding common methods.
public protocol Node { }

/// Contains computed constants
public extension Node {
    /// Returns the name of the type as a string
    var objectName: String {
        return "\(type(of: self))"
    }

    /// Name of the object in following format:
    /// <<<===\(self.objectName)===>>>" + `String.lineTabDeilimeter`
    var logViewObjectName: String {
        return "<<<===\(self.objectName)===>>>" + .lineTabDeilimeter
    }
}
