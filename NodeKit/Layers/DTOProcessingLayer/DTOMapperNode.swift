//
//  DTOMapperNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 18/12/2018.
//  Copyright © 2018 Кравченков Александр. All rights reserved.
//

import Foundation

/// Этот узел отвечает за маппинг верхнего уровня DTO (`DTOConvertible`) в нижний уровень (`RawMappable`) и наборот.
open class DTOMapperNode<Input, Output>: AsyncNode where Input: RawEncodable, Output: RawDecodable {

    /// Следующий узел для обрабтки.
    public var next: any AsyncNode<Input.Raw, Output.Raw>

    /// Инциаллизирует узел.
    ///
    /// - Parameter next: Следующий узел для обрабтки.
    public init(next: any AsyncNode<Input.Raw, Output.Raw>) {
        self.next = next
    }

    /// Маппит данные в RawMappable, передает управление следующей цепочке, а затем маппит ответ в DTOConvertible
    ///
    /// - Parameter data: Данные для обработки.
    open func processLegacy(_ data: Input) -> Observer<Output> {
        let context = Context<Output>()

        var log = Log(self.logViewObjectName, id: self.objectName, order: LogOrder.dtoMapperNode)
                
        do {
            let data = try data.toRaw()
            
            let nextProcessResult = next.processLegacy(data)
            
            return nextProcessResult.map { [weak nextProcessResult] result in
                do {
                    let model = try Output.from(raw: result)
                    return Context<Output>().log(nextProcessResult?.log).emit(data: model)
                } catch {
                    log += "\(error)"
                    return Context<Output>().log(nextProcessResult?.log).log(log).emit(error: error)
                }
            }
        } catch {
            return context.log(log).emit(error: error)
        }
    }

    /// Маппит данные в RawMappable, передает управление следующей цепочке, а затем маппит ответ в DTOConvertible
    ///
    /// - Parameter data: Данные для обработки.
    open func process(
        _ data: Input,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<Output> {
        return await .withMappedExceptions {
            let raw = try data.toRaw()
            return .success(raw)
        }
        .asyncFlatMapError { error in
            await log(error: error, logContext: logContext)
            return .failure(error)
        }
        .asyncFlatMap { data in
            await next.process(data, logContext: logContext)
        }
        .asyncFlatMap { result in
            await .withMappedExceptions {
                let output = try Output.from(raw: result)
                return .success(output)
            }
            .asyncFlatMapError { error in
                await log(error: error, logContext: logContext)
                return .failure(error)
            }
        }
    }

    private func log(error: Error, logContext: LoggingContextProtocol) async {
        let log = Log(
            logViewObjectName + "\(error)",
            id: objectName,
            order: LogOrder.dtoMapperNode
        )
        await logContext.add(log)
    }
}
