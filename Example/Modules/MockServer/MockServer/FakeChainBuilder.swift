//
//  FakeChainBuilder.swift
//
//
//  Created by Andrei Frolov on 02.05.24.
//

import NodeKit
import NodeKitMock

public final class FakeChainBuilder<Route: URLRouteProvider>: URLChainBuilder<Route> {
    
    public init() {
        super.init(
            serviceChainProvider: URLServiceChainProvider(session: NetworkMock().urlSession)
        )
    }
}
