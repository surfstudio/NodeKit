//
//  GroupService.swift
//
//
//  Created by Andrei Frolov on 15.04.24.
//

import Foundation
import NodeKit
import Models
import MockServer

public protocol GroupServiceProtocol {
    func header() async -> NodeResult<GroupHeaderResponseEntity>
    func body() async -> NodeResult<GroupBodyResponseEntity>
    func footer() async -> NodeResult<GroupFooterResponseEntity>
}

public final class GroupService: GroupServiceProtocol {
    
    public init() { }
    
    public func header() async -> NodeResult<GroupHeaderResponseEntity> {
        return await result(from: .header)
    }
    
    public func body() async -> NodeResult<GroupBodyResponseEntity> {
        return await result(from: .body)
    }
    
    public func footer() async -> NodeResult<GroupFooterResponseEntity> {
        return await result(from: .footer)
    }
    
    private func result<T: DTODecodable>(
        from route: GroupURLProvider
    ) async -> NodeResult<T> where T.DTO.Raw == Json {
        return await FakeChainBuilder<GroupURLProvider>()
            .route(.get, route)
            .build()
            .process()
    }
}
