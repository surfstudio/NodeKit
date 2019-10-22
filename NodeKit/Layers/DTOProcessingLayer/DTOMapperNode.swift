//
//  DTOMapperNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 18/12/2018.
//  Copyright © 2018 Кравченков Александр. All rights reserved.
//

import Foundation

/// Этот узел отвечает за маппинг верхнего уровня DTO (`DTOConvertible`) в нижний уровень (`RawMappable`) и наборот.
open class DTOMapperNode<Input, Output>: Node<Input, Output> where Input: RawEncodable, Output: RawDecodable {

    /// Следующий узел для обрабтки.
    public var next: Node<Input.Raw, Output.Raw>

    /// Инциаллизирует узел.
    ///
    /// - Parameter next: Следующий узел для обрабтки.
    public init(next: Node<Input.Raw, Output.Raw>) {
        self.next = next
    }

    /// Маппит данные в RawMappable, передает управление следующей цепочке, а затем маппит ответ в DTOConvertible
    ///
    /// - Parameter data: Данные для обработки.
    open override func process(_ data: Input) -> Observer<Output> {
        let context = Context<Output>()

        var log = Log(self.logViewObjectName, id: self.objectName, order: LogOrder.dtoMapperNode)
                
        do {
            let data = try data.toRaw()
            
            let nextProcessResult = next.process(data)
            
            return nextProcessResult.map {
                do {
                    let model = try Output.from(raw: $0)
                    return Context<Output>().log(nextProcessResult.log).emit(data: model)
                } catch {
                    log += "\(error)"
                    return Context<Output>().log(nextProcessResult.log).log(log).emit(error: error)
                }
            }
        } catch {
            return context.log(log).emit(error: error)
        }
    }
}
