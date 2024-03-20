//
//  EntryinputDtoOutputNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 15/04/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

open class EntryinputDtoOutputNode<Input, Output>: Node
                                                    where Input: RawEncodable, Output: DTODecodable {

    open var next: any Node<Input.Raw, Output.DTO.Raw>

    init(next: any Node<Input.Raw, Output.DTO.Raw>) {
        self.next = next
    }

    open func process(_ data: Input) -> Observer<Output> {
        do {
            let raw = try data.toRaw()
            return self.next.process(raw).map { try Output.from(dto: Output.DTO.from(raw: $0) ) }
        } catch {
            return .emit(error: error)
        }
    }

    open func process(
        _ data: Input,
        logContext: LoggingContextProtocol
    ) async -> Result<Output, Error> {
        return await .withMappedExceptions {
            let raw = try data.toRaw()
            return try await next.process(raw, logContext: logContext).map {
                let dto = try Output.DTO.from(raw: $0)
                return try Output.from(dto: dto)
            }
        }
    }

}
