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
@available(iOS 13.0, *)
public class ModelInputNode<Input, Output>: Node<Input, Output> where Input: DTOEncodable, Output: DTODecodable {

    /// Следующий узел для обработки.
    public var next: Node<Input.DTO, Output.DTO>

    /// Инциаллизирует узел.
    ///
    /// - Parameter next: Следующий узел для обработки.
    public init(next: Node<Input.DTO, Output.DTO>) {
        self.next = next
    }

    /// Передает управление следующему узлу,
    /// а по получении ответа пытается замапить нижний DTO-слой на верхний.
    /// Если при маппинге произошла ошибка, то она будет проброшена выше.
    ///
    /// - Parameter data: Данные для запроса.
    open override func process(_ data: Input) async -> Result<Output, Error> {
        return await .withMappedExceptions {
            let data = try data.toDTO()
            return try await next.process(data).map { try Output.from(dto: $0) }
        }
    }
}
