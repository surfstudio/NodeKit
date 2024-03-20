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
open class DataLoadingResponseProcessor: Node {

    /// Узел для постобработки загруженных данных.
    open var next: (any Node<UrlDataResponse, Void>)?

    /// Инициаллизирует узел.
    ///
    /// - Parameter next: Узел для постобработки загруженных данных. По-умолчанию nil.
    public init(next: (any Node<UrlDataResponse, Void>)? = nil) {
        self.next = next
    }

    /// В случае, если узел для постобработки существует, то вызывает его, если нет - возвращает данные.
    open func process(_ data: UrlDataResponse) -> Observer<Data> {
        guard let next = self.next else {
            return .emit(data: data.data)
        }

        return next.process(data).map { data.data }
    }

    /// В случае, если узел для постобработки существует, то вызывает его, если нет - возвращает данные.
    open func process(
        _ data: UrlDataResponse,
        logContext: LoggingContextProtocol
    ) async -> Result<Data, Error> {
        return await next?.process(data, logContext: logContext)
            .map { data.data } ?? .success(data.data)
    }
}
