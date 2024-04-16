//
//  PaginationPresenter.swift
//  Example
//
//  Created by Alexander Kravchenkov on 09.04.2018.
//  Copyright © 2018 Кравченков Александр. All rights reserved.
//

import Foundation
import Models
import NodeKit
import ReactiveDataDisplayManager

protocol PaginationViewOutput {
    func viewDidLoad()
    func nextPageRequested()
    func refreshDidRequest()
}

class PaginationPresenter {
    
    // MARK: - Private Properties
    
    private weak var input: PaginationViewInput?
    private let router: PaginationRouterInput
    private let iterator: any AsyncIterator<[PaginationResponseEntity]>
    
    // MARK: - Initialization
    
    init(
        input: PaginationViewInput,
        router: PaginationRouterInput,
        iterator: some AsyncIterator<[PaginationResponseEntity]>
    ) {
        self.input = input
        self.router = router
        self.iterator = iterator
    }
}

// MARK: - PaginationViewOutput

extension PaginationPresenter: PaginationViewOutput {
    
    func viewDidLoad() {
        startLoad()
    }
    
    func nextPageRequested() {
        Task {
            if let generators = await next()?.value {
                await input?.add(generators: generators)
            }
        }
    }
    
    func refreshDidRequest() {
        Task {
            await iterator.renew()
            startLoad()
        }
    }
}

// MARK: - Private Methods

private extension PaginationPresenter {
    
    func startLoad() {
        Task {
            if let generators = await next()?.value {
                await input?.update(with: generators)
            }
        }
    }
    
    func next() async -> Result<[TableCellGenerator], Error>? {
        guard await iterator.hasNext() else {
            await input?.disablePagination()
            return nil
        }
        
        await input?.enablePagination()
        
        return await iterator.next()
            .map { models in
                return models.map {
                    return PaginationCellGenerator(name: $0.name, url: $0.image)
                }
            }
            .asyncFlatMapError {
                await router.show(error: $0)
                return .failure($0)
            }
    }
}
