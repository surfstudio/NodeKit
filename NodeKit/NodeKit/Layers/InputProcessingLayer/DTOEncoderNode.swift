//
//  DTOConverterNode.swift
//  NodeKit
//
//  Created by Александр Кравченков on 18/05/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// Этот узел умеет конвертировать ВХОДНЫЕ данные в DTO, НО не пытается декодировать ответ.
open class DTOEncoderNode<Input, Output>: AsyncNode where Input: DTOEncodable {

    /// Узел, который умеет работать с DTO
    open var rawEncodable: any AsyncNode<Input.DTO, Output>

    /// Инициаллизирует объект
    ///
    /// - Parameter rawEncodable: Узел, который умеет работать с DTO.
    public init(rawEncodable: some AsyncNode<Input.DTO, Output>) {
        self.rawEncodable = rawEncodable
    }

    /// Пытается конвертировать модель в DTO, а затем просто передает результат конвертации следующему узлу.
    /// Если при конвертировании произошла ошибка - прерывает выполнение цепочки.
    ///
    /// - Parameter data: Входящая модель.
    open func process(
        _ data: Input,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<Output> {
        return await .withMappedExceptions {
            await rawEncodable.process(try data.toDTO(), logContext: logContext)
        }
    }
}
