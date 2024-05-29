//
//  NodeSubscriber.swift
//  NodeKit
//
//  Created by Andrei Frolov on 17.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import Combine

/// Short name for a Subscriber expecting NodeResult
typealias NodeSubscriber<Node: CombineCompatibleNode> = Subscriber<NodeResult<Node.O>, Never>
