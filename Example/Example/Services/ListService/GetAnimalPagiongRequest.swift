//
//  GetAnimalPagiongRequest.swift
//  Example
//
//  Created by Alexander Kravchenkov on 06.04.2018.
//  Copyright © 2018 Кравченков Александр. All rights reserved.
//

import Foundation
import CoreNetKit

public class GetAnimalPagingRequest: BaseServerRequest<[AnimalEntity]>, ReusablePagingRequest {

    private struct Keys {
        static let index = "index"
        static let offset = "offset"
    }

    private var startIndex = 0
    private var itemsOnPage = 0

    public override init() {
        self.itemsOnPage = 0
        self.startIndex = 0
    }

    public override func createAsyncServerRequest() -> CoreServerRequest {
        let params = [Keys.index: self.startIndex, Keys.offset: self.itemsOnPage]
        return BaseCoreServerRequest(method: .get, baseUrl: Urls.base, relativeUrl: Urls.Animals.list, headers: ["Content-Type": "application/json"], parameters: .simpleParams(params))
    }

    public func reuse(startIndex: Int, itemsOnPage: Int) {
        self.startIndex = startIndex
        self.itemsOnPage = itemsOnPage
    }

    public override func handle(serverResponse: CoreServerResponse, completion: (ResponseResult<[AnimalEntity]>) -> Void) {
        switch serverResponse.result {
        case .failure(let error):
            completion(.failure(error))
        case .success(let val, let cacheFlag):
            guard let arr = val as? [[String: Any]] else {
                completion(.failure(BaseServerError.badJsonFormat))
                return
            }

            var result = [AnimalEntity]()

            arr.forEach { (dict) in
                guard let animal = AnimalEntity(json: dict) else {
                    completion(.failure(BaseServerError.badJsonFormat))
                    return
                }
                result.append(animal)
            }

            completion(.success(result, cacheFlag))
        }
    }
}
