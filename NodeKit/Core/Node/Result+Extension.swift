//
//  Result+Extension.swift
//  NodeKit
//
//  Created by frolov on 14.02.2024.
//  Copyright © 2024 Surf. All rights reserved.
//

open class NodeResult {
    public var log: Logable?

    @discardableResult
    open func log(_ log: Logable?) -> Self {
        guard var selfLog = self.log else {
            self.log = log
            return self
        }

        if selfLog.next == nil {
            selfLog.next = log
        } else {
            var temp = log
            temp?.next = selfLog.next
            selfLog.next = temp
        }

        self.log = selfLog
        return self
    }
}

@available(iOS 13.0, *)
extension Result {
    @inlinable public func flatMap<NewSuccess>(
        _ transform: (Success) async -> Result<NewSuccess, Failure>
    ) async -> Result<NewSuccess, Failure> {
        switch self {
        case .success(let success):
            return await transform(success)
        case .failure(let error):
            return .failure(error)
        }
    }

    @inlinable public func flatMapError<NewFailure>(
        _ transform: (Failure) async -> Result<Success, NewFailure>
    ) async -> Result<Success, NewFailure> where NewFailure : Error {
        switch self {
        case .success(let data):
            return .success(data)
        case .failure(let error):
            return await transform(error)
        }
    }

    @inlinable public func map<NewSuccess>(_ transform: (Success) throws -> NewSuccess) rethrows -> Result<NewSuccess, Failure> {
        switch self {
        case .success(let data):
            return try .success(transform(data))
        case .failure(let error):
            return .failure(error)
        }
    }

    static func withMappedExceptions<T>(
        _ customError: Error? = nil,
        _ function: () async throws -> Result<T, Error>
    ) async -> Result<T, Error> {
        do {
            return try await function()
        } catch {
            return .failure(customError ?? error)
        }
    }
}
