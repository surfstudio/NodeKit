//
//  NodeResult.swift
//  NodeKit
//
//  Created by Andrei Frolov on 22.03.24.
//  Copyright © 2024 Surf. All rights reserved.
//

/// Результат метода обработки данных узла.
public typealias NodeResult<Output> = Result<Output, Error>

extension NodeResult {
    
    /// Метод асинхронной трансформации положительного результата
    ///
    /// - Parameter transform: Ассинхронная функция трансформации положительного результата
    /// - Returns: Результат применения трансформации.
    @inlinable public func asyncFlatMap<NewSuccess>(
        _ transform: (Success) async -> NodeResult<NewSuccess>
    ) async -> NodeResult<NewSuccess> {
        switch self {
        case .success(let success):
            return await transform(success)
        case .failure(let error):
            return .failure(error)
        }
    }

    /// Метод асинхронной трансформации ошибки
    ///
    /// - Parameter transform: Ассинхронная функция трансформации ошибки
    /// - Returns: Результат применения трансформации.
    @inlinable public func asyncFlatMapError(
        _ transform: (Failure) async -> NodeResult<Success>
    ) async -> NodeResult<Success> {
        switch self {
        case .success(let data):
            return .success(data)
        case .failure(let error):
            return await transform(error)
        }
    }

    /// Метод трансформации положительного результата, способный выкинуть Exception
    ///
    /// - Parameter transform: Функция трансформации ошибки, способная выкинуть Exception
    /// - Returns: Результат применения трансформации или Exception.
    @inlinable public func map<NewSuccess>(
        _ transform: (Success) throws -> NewSuccess
    ) rethrows -> NodeResult<NewSuccess> {
        switch self {
        case .success(let data):
            return try .success(transform(data))
        case .failure(let error):
            return .failure(error)
        }
    }

    /// Метод вызывает ассинхронную функцию и оборачивает пойманные Exceptions в failure(error)
    ///
    /// - Parameter customError: Ошибка, которая будет передаваться в failure вместо Exeception
    /// - Parameter function: Ассинхронная функция, способная выкинуть Exception
    /// - Returns: Результат с преобразованными Exceptions в failure.
    static func withMappedExceptions<T>(
        _ customError: Error? = nil,
        _ function: () async throws -> NodeResult<T>
    ) async -> Result<T, Error> {
        do {
            return try await function()
        } catch {
            return .failure(customError ?? error)
        }
    }
}
