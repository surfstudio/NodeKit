//
//  PaginationContentDataProvider.swift
//
//  Created by Andrei Frolov on 15.04.24.
//

import Models
import NodeKit
import MockServer

public struct PaginationContentDataProvider: AsyncPagerDataProvider {
    public typealias Value = [PaginationResponseEntity]
    
    public init() { }
    
    public func provide(for index: Int, with pageSize: Int) async -> NodeResult<AsyncPagerData<[PaginationResponseEntity]>> {
        return await FakeChainBuilder<PaginationURLProvider>()
            .encode(as: .urlQuery)
            .route(.get, .list)
            .build()
            .process(PaginationRequestEntity(index: index, pageSize: pageSize))
            .map { AsyncPagerData(value: $0, len: $0.count) }
    }
}
