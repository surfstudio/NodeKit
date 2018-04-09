//
//  AnimalPresenter.swift
//  Example
//
//  Created by Alexander Kravchenkov on 09.04.2018.
//  Copyright © 2018 Кравченков Александр. All rights reserved.
//

import Foundation
import CoreNetKit

class AnimalPresernter {
    var view: AnimalViewController?

    private var pagingContext: IteratableContext<[AnimalEntity]>?

    func loadAnimals() {
        self.pagingContext = ListService().getIterator(with: 0, itemsOnPage: 10)
            .onCompleted({ (entity) in
                self.view?.add(models: entity)
            })
            .onError({ (error) in
                self.view?.showError(error)
            })
        self.next()
    }

    func next() {
        guard self.pagingContext?.canMoveNext == true else {
            return
        }
        self.pagingContext?.moveNext()
    }
}
