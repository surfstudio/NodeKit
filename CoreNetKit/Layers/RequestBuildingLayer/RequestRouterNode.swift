//
//  RequestRouterNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 05/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

open class RequestRouterNode<Raw, Route, Output>: Node<RequestModel<Raw>, Output> {

    public typealias NextNode = Node<RoutableRequestModel<Route, Raw>, Output>

    public var next: NextNode
    public var route: Route

    public init(next: NextNode, route: Route) {
        self.next = next
        self.route = route
    }

    open override func process(_ data: RequestModel<Raw>) -> Observer<Output> {
        return self.next.process(RoutableRequestModel(metadata: data.metadata, raw: data.raw, route: self.route))
    }
}
