//
//  RequstEncoderNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 05/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

open class RequstEncoderNode<Raw, Route, Encoding, Output>: RequestRouterNode<Raw, Route, Output>.NextNode {

    public typealias NextNode = Node<EncodableRequestModel<Route, Raw, Encoding>, Output>

    public var next: NextNode
    public var encoding: Encoding

    public init(next: NextNode, encoding: Encoding) {
        self.next = next
        self.encoding = encoding
    }

    open override func process(_ data: RoutableRequestModel<Route, Raw>) -> Observer<Output> {
        let model = EncodableRequestModel(metadata: data.metadata, raw: data.raw, route: data.route, encoding: self.encoding)
        return self.next.process(model)
    }
}
