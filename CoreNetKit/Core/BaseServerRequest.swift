//
//  BaseRequest.swift
//  Sample
//
//  Created by Alexander Kravchenkov on 06.07.17.
//  Copyright © 2017 Alexander Kravchenkov. All rights reserved.
//

import Foundation
import Alamofire

open class BaseServerRequest<ResultValueType> {

    public typealias RequestCompletion = (ResponseResult<ResultValueType>) -> Void

    // MARK: - Properties

    private var currentRequest: CoreServerRequest?

    // MARK: - Internal methods

    /// Выполняет асинхронный запрос
    ///
    /// - Parameter completion: Комплишн блок. Вызывается после выполнения запроса
    public func performAsync(with completion: @escaping RequestCompletion) {
        currentRequest = self.createAsyncServerRequest()
        currentRequest?.perform(with: { serverResponse in
            self.handle(serverResponse: serverResponse, completion: completion)
            self.currentRequest = nil
        })
    }

    open func cancel() {
        currentRequest?.cancel()
    }

    // MARK: - Must be overriden methods

    /// Создает асинхронный запрос. необходимо переопределение в потомке
    ///
    /// - Return: Сконфигурированный запрос к серверу
    open func createAsyncServerRequest() -> CoreServerRequest {
        preconditionFailure("This method must be overriden by the subclass")
    }

    /// Обработка ответа сервера. При необходимости можно перегрузить метод.
    open func handle(serverResponse: CoreServerResponse, completion: RequestCompletion) {
        preconditionFailure("This method must be overriden by the subclass")
    }
}
