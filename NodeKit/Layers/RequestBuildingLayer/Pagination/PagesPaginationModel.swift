//
//  PagesPaginationModel.swift
//  NodeKit
//
//  Created by Alena Belyaeva on 22.04.2020.
//  Copyright © 2020 Кравченков Александр. All rights reserved.
//

import Foundation

/// Модель пагинации основанной на страницах и смещениях (offset)
/// Дефолтное значение первой страницы 0
public class PagesPaginationModel: PaginationModel {

    // MARK: - Private properties
    
    private var firstPageNumber: Int = 0
    private var currentPageNumber: Int = 0
    private var pageSize: Int
    private var pageSizeKey: String
    private var pageKey: String

    // MARK: - Initialization

    public init(pageSize: Int, pageSizeKey: String, firstPageNumber: Int = 0, pageKey: String) {
        self.firstPageNumber = firstPageNumber
        self.currentPageNumber = firstPageNumber
        self.pageSize = pageSize
        self.pageSizeKey = pageSizeKey
        self.pageKey = pageKey
    }

    // MARK: - PaginationBuilder methods

    public var encoding: ParametersEncoding {
        return .urlQuery
    }

    public var parameters: [String : Any] {
        return [
            pageSizeKey: pageSize,
            pageKey: currentPageNumber
        ]
    }

    public func next(customIndexesUpdate: [String: Any] = [:]) {
        self.currentPageNumber += 1
    }

    public func renew() {
        self.currentPageNumber = firstPageNumber
    }

}
