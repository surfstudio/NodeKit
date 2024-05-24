//
//  URLCacheWriterNode.swift
//  CoreNetKitWithExample
//
//  Created by Александр Кравченков on 28/11/2018.
//  Copyright © 2018 Александр Кравченков. All rights reserved.
//

import Foundation

/// Этот узел занимается записью данных в URL кэш.
/// - Important: это "глупая" реализация,
/// в которой не учитываются server-side политики и прочее.
/// Подразумечается, что этот узел не входит в цепочку, а является листом одного из узлов.
open class URLCacheWriterNode: AsyncNode {

    /// Формирует `CachedURLResponse` с политикой `.allowed`, сохраняет его в кэш,
    /// а затем возвращает сообщение об успешной операции.
    open func process(
        _ data: URLProcessedResponse,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<Void> {
        await .withCheckedCancellation {
            let cached = CachedURLResponse(
                response: data.response,
                data: data.data,
                storagePolicy: .allowed
            )
            URLCache.shared.storeCachedResponse(cached, for: data.request)
            return .success(())
        }
    }
}
