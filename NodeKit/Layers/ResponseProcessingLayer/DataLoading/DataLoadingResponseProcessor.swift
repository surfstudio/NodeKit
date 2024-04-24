//
//  DataLoadingResponseProcessor.swift
//  NodeKit
//
//  Created by Александр Кравченков on 18/05/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// Этот узел просто возвращает набор байт из запроса.
/// Должен использоваться для тех случаях, когда конвертирование в JSON не нужно или не возможно (например загрузка картинок)
/// Содержит указание на следующий узел, который нужен для постобработки.
/// Например может использоваться для сохранения.
open class DataLoadingResponseProcessor: AsyncNode {

    /// Узел для постобработки загруженных данных.
    open var next: (any AsyncNode<UrlDataResponse, Void>)?

    /// Инициаллизирует узел.
    ///
    /// - Parameter next: Узел для постобработки загруженных данных. По-умолчанию nil.
    public init(next: (any AsyncNode<UrlDataResponse, Void>)? = nil) {
        self.next = next
    }

    /// В случае, если узел для постобработки существует, то вызывает его, если нет - возвращает данные.
    open func process(
        _ data: UrlDataResponse,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<Data> {
        return await next?.process(data, logContext: logContext)
            .map { data.data } ?? .success(data.data)
    }
}
