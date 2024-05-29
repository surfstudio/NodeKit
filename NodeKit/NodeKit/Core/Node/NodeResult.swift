//
//  NodeResult.swift
//  NodeKit
//
//  Created by Andrei Frolov on 22.03.24.
//  Copyright © 2024 Surf. All rights reserved.
//

/// Result of the node's data processing method.
public typealias NodeResult<Output> = Result<Output, Error>

public extension NodeResult {
    
    /// Asynchronous positive result transformation method
    ///
    /// - Parameter transform: Asynchronous function to transform the positive result
    /// - Returns: The result of applying the transformation.
    @inlinable func asyncFlatMap<NewSuccess>(
        _ transform: (Success) async -> NodeResult<NewSuccess>
    ) async -> NodeResult<NewSuccess> {
        switch self {
        case .success(let success):
            return await transform(success)
        case .failure(let error):
            return .failure(error)
        }
    }

    /// Asynchronous error transformation method
    ///
    /// - Parameter transform: Asynchronous function to transform the error
    /// - Returns: The result of applying the transformation.
    @inlinable func asyncFlatMapError(
        _ transform: (Failure) async -> NodeResult<Success>
    ) async -> NodeResult<Success> {
        switch self {
        case .success(let data):
            return .success(data)
        case .failure(let error):
            return await transform(error)
        }
    }

    /// Positive result transformation method that can throw an Exception
    ///
    /// - Parameter transform: Transformation function that can throw an Exception
    /// - Returns: The result of applying the transformation or an Exception.
    @inlinable func map<NewSuccess>(
        _ transform: (Success) throws -> NewSuccess
    ) rethrows -> NodeResult<NewSuccess> {
        switch self {
        case .success(let data):
            return try .success(transform(data))
        case .failure(let error):
            return .failure(error)
        }
    }

    /// Method that calls an asynchronous function and wraps caught Exceptions in a failure(error)
    ///
    /// - Parameters:
    ///   - customError: The error that will be passed to failure instead of the Exception
    ///   - function: Asynchronous function that can throw an Exception
    /// - Returns: The result with transformed Exceptions into failure.
    @inlinable static func withMappedExceptions<T>(
        _ customError: Error? = nil,
        _ function: () async throws -> NodeResult<T>
    ) async -> NodeResult<T> {
        do {
            return try await function()
        } catch {
            return .failure(customError ?? error)
        }
    }
    
    /// Method that calls an asynchronous function, checking if the task is still alive.
    /// If the task was canceled, it returns a `CancellationError`.
    ///
    /// - Parameters:
    ///   - function: Asynchronous function.
    /// - Returns: The result of the passed method.
    @inlinable static func withCheckedCancellation<T>(
        _ function: () async -> NodeResult<T>
    ) async -> NodeResult<T> {
        do {
            try Task.checkCancellation()
            let result = await function()
            try Task.checkCancellation()
            return result
        } catch {
            return .failure(error)
        }
    }
    
    /// Returns the value of a successful result or nil if Failure.
    var value: Success? {
        switch self {
        case .success(let value):
            return value
        case .failure:
            return nil
        }
    }
    
    /// Returns the Error if Failure, or nil if Success.
    var error: Error? {
        switch self {
        case .success:
            return nil
        case .failure(let error):
            return error
        }
    }
}
