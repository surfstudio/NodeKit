//
//  ModelInputNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 18/12/2018.
//  Copyright © 2018 Кравченков Александр. All rights reserved.
//

import Foundation

/// Узел для инциаллизации обработки данных.
/// Иcпользуется для работы с моделями, которые представлены двумя слоями DTO.
public class ModelInputNode<Input, Output>: AsyncNode where Input: DTOEncodable, Output: DTODecodable {

    /// Следующий узел для обработки.
    public var next: any AsyncNode<Input.DTO, Output.DTO>

    /// Инциаллизирует узел.
    ///
    /// - Parameter next: Следующий узел для обработки.
    public init(next: any AsyncNode<Input.DTO, Output.DTO>) {
        self.next = next
    }

    /// Передает управление следующему узлу,
    /// а по получении ответа пытается замапить нижний DTO-слой на верхний.
    /// Если при маппинге произошла ошибка, то она будет проброшена выше.
    ///
    /// - Parameter data: Данные для запроса.
    open func process(
        _ data: Input,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<Output> {
        return await .withMappedExceptions {
            let data = try data.toDTO()
            return try await next.process(data, logContext: logContext)
                .map { try Output.from(dto: $0) }
        }
    }
}
