//
//  PaginationModel.swift
//  NodeKit
//
//  Created by Alena Belyaeva on 15/01/2020.
//  Copyright © 2020 Кравченков Александр. All rights reserved.
//

import Foundation

public enum PaginationType {

    // offset-limit, предусмотрены кастомные ключи
    case offset(limit: Int, offsetKey: String? = nil, limitKey: String? = nil)
    // Cтраничная пагинация - где задается рамзмер страницы и номер первой страницы для запроса
    case pages(pageSize: Int, pageSizeKey: String, firstPageNumber: Int = 0, pageKey: String)
    // Cursor
    case cursor(pageSize: Int, pageSizeKey: String, pageAfterKey: String, pageBeforeKey: String)

}

public class PaginationModel {

    // MARK: - Constants

    private enum Constants {
        static let defaultOffsetKey = "offset"
        static let defaultLimitKey = "limit"
    }
    // MARK: - Properties

    var query: [String: Any] {
        switch type {
        case let .offset(limit, offsetKey, limitKey):
            return [
                offsetKey ?? Constants.defaultOffsetKey: offset,
                limitKey ?? Constants.defaultLimitKey: limit
            ]
        case let .pages(pageSize, pageSizeKey, _, pageKey):
            return [
                pageSizeKey: pageSize,
                pageKey: pageNumber
            ]
        case let .cursor(pageSize, pageSizeKey, pageAfterKey, pageBeforeKey):
            var query: [String: Any] = [pageSizeKey: pageSize]
            if let after = pageAfter {
                query[pageAfterKey] = after
            }
            if let before = pageBefore {
                query[pageBeforeKey] = before
            }
            return query
        }
    }

    // MARK: - Private properties

    private var type: PaginationType = .offset(limit: 10)
    // .offset
    private var offset: Int = 0

    // .pages
    private var pageNumber: Int = 0

    // .cursor
    private var pageAfter: Any?
    private var pageBefore: Any?

    // MARK: - Initialization

    public init(type: PaginationType) {
        self.type = type
        switch type {
        case .offset:
            break
        case let .pages(_, _, firstPageNumber, _):
            self.pageNumber = firstPageNumber
        case .cursor:
            break
        }
    }

    // MARK: - Public methods

    // для обработки следующей "страницы" передавать данные необходимо только для coursor - так как их сложно унифицировать
    public func next(forCursor pageAfter: Any? = nil, pageBefore: Any? = nil) {
        switch type {
        case let .offset(limit, _, _):
            self.offset += limit
        case .pages:
            self.pageNumber += 1
        case .cursor:
            self.pageAfter = pageAfter
            self.pageBefore = pageBefore
        }
    }

    // Сброс начальных настроек для первой "страницы" пагинации
    public func renew() {
        self.pageNumber = 0
        self.offset = 0
        self.pageAfter = nil
        self.pageBefore = nil
    }

}
