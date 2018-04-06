//
//  ListService.swift
//  Example
//
//  Created by Alexander Kravchenkov on 06.04.2018.
//  Copyright © 2018 Кравченков Александр. All rights reserved.
//

import Foundation
import CoreNetKit

class ListService {
    
    func getIterator(with start: Int, itemsOnPage: Int) -> IteratableContext<[AnimalEntity]> {
        let request = GetAnimalPagingRequest()
        let pagingContext = PagingRequestContext(request: request)

        return IteratableContext<[AnimalEntity]>(startIndex: start, itemsOnPage: itemsOnPage, context: pagingContext)
    }
}
