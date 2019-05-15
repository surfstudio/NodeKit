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
    open override func process(_ data: Input) -> Observer<Output> {

        let context = Context<Output>()

        do {
            let data = try data.toDTO()
            return next.process(data)
                .map { try Output.from(dto: $0) }
        } catch {
            return context.emit(error: error)
        }
    }
}
