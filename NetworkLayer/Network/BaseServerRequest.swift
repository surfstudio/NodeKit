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

    typealias RequestCompletion = (ResponseResult<ResultValueType>) -> Void

    // MARK: - Properties

    lazy var asyncServerRequest: ServerRequest = { [unowned self] in
        return self.createAsyncServerRequest()
    }()

    lazy var syncServerRequst: SyncServerRequest = { [unowned self] in
        return self.createSyncServerRequest()
    }()

    private var currentRequest: ServerRequest?

    // MARK: - Internal methods

    /// Выполняет асинхронный запрос
    ///
    /// - Parameter completion: Комплишн блок. Вызывается после выполнения запроса
    func performAsync(with completion: @escaping RequestCompletion) {
        currentRequest = asyncServerRequest
        currentRequest?.perform(with: { serverResponse in
            self.handle(serverResponse: serverResponse, completion: completion)
            self.currentRequest = nil
        })
    }

    /// Выполняет синхронный запрос. Является оберткой над performAsync
    ///
    /// - Return: результат выполнения запроса
    func performSync() -> ResponseResult<ResultValueType> {
        var result: ResponseResult<ResultValueType>!
        currentRequest = syncServerRequst
        currentRequest?.perform(with: { serverResponse in
            self.handle(serverResponse: serverResponse, completion: { handleResult in
                result = handleResult
            })
            self.currentRequest = nil
        })
        return result
    }

    func cancel() {
        currentRequest?.cancel()
    }

    // MARK: - Must be overriden methods

    /// Создает асинхронный запрос. необходимо переопределение в потомке
    ///
    /// - Return: Сконфигурированный запрос к серверу
    func createAsyncServerRequest() -> ServerRequest {
        preconditionFailure("This method must be overriden by the subclass")
    }

    /// Создает синхронный запрос. необходимо переопределение в потомке
    ///
    /// - Return: Сконфигурированный запрос к серверу
    func createSyncServerRequest() -> SyncServerRequest {
        preconditionFailure("This method must be overriden by the subclass")
    }

    /// Обработка ответа сервера. При необходимости можно перегрузить метод.
    func handle(serverResponse: ServerResponse, completion: RequestCompletion) {
        preconditionFailure("This method must be overriden by the subclass")
    }
}
