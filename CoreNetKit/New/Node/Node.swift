//
//  Node.swift
//  CoreNetKitWithExample
//
//  Created by Александр Кравченков on 27/11/2018.
//  Copyright © 2018 Александр Кравченков. All rights reserved.
//

import Foundation

protocol NodeProtocol {

    associatedtype Input
    associatedtype Output

    func input(_ data: Input) -> Context<Output>
}

class Node<Input, Output>: NodeProtocol {
    func input(_ data: Input) -> Context<Output> {
        fatalError("\(self.self) \(#function) must be overriden in subclass")
    }
}
