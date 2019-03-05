//
//  MetadataConnectorNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 05/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

open class MetadataConnectorNode<Raw, Output>: Node<Raw, Output> {

    public var next: Node<RequestModel<Raw>, Output>
    public var metadata: [String: String]

    public init(next: Node<RequestModel<Raw>, Output>, metadata: [String: String]) {
        self.next = next
        self.metadata = metadata
    }

    open override func process(_ data: Raw) -> Observer<Output> {
        return next.process(RequestModel(metadata: self.metadata, raw: data))
    }
}
