//
//  CursorPaginationModel.swift
//  NodeKit
//
//  Created by Alena Belyaeva on 22.04.2020.
//  Copyright © 2020 Кравченков Александр. All rights reserved.
//

import Foundation

public class CursorPaginationModel: PaginationModel {

    // MARK: - Private properties

    private var pageSize: Int
    private var pageAfter: Any?
    private var pageBefore: Any?
    private var pageSizeKey: String
    private var pageAfterKey: String
    private var pageBeforeKey: String

    // MARK: - Initialization

    public init(pageSize: Int, pageSizeKey: String, pageAfterKey: String, pageBeforeKey: String) {
        self.pageSize = pageSize
        self.pageSizeKey = pageSizeKey
        self.pageAfterKey = pageAfterKey
        self.pageBeforeKey = pageBeforeKey
    }

    // MARK: - PaginationBuilder methods

    public var encoding: ParametersEncoding {
        return .urlQuery
    }

    public var parameters: [String : Any] {
        var query: [String: Any] = [pageSizeKey: pageSize]
        if let after = pageAfter {
            query[pageAfterKey] = after
        }
        if let before = pageBefore {
            query[pageBeforeKey] = before
        }
        return query
    }

    public func next(customIndexesUpdate: [String: Any]) {
        self.pageAfter = customIndexesUpdate[pageAfterKey]
        self.pageBefore = customIndexesUpdate[pageBeforeKey]
    }

    public func renew() {
        self.pageAfter = nil
        self.pageBefore = nil
    }

}
