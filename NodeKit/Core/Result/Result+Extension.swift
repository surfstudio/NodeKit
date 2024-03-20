//
//  Result+Extension.swift
//  NodeKit
//
//  Created by frolov on 20.03.2024.
//  Copyright © 2024 Surf. All rights reserved.
//

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
