//
//  OffsetPaginationModel.swift
//  NodeKit
//
//  Created by Alena Belyaeva on 15/01/2020.
//  Copyright © 2020 Кравченков Александр. All rights reserved.
//

import Foundation

/// Модель пагинации основанной на лимитах и смещениях (offset)
/// Есть дефолтныые ключи для переменных
/// Но есть возможность задавать кастомные
public class OffsetPaginationModel: PaginationModel {

    // MARK: - Constants

    private enum Constants {
        static let defaultOffsetKey = "offset"
        static let defaultLimitKey = "limit"
    }

    // MARK: - Private properties

    private var offset: Int = 0
    private var limit: Int
    private var offsetKey: String?
    private var limitKey: String?

    // MARK: - Initialization

    public init(limit: Int, offsetKey: String? = nil, limitKey: String? = nil) {
        self.limit = limit
        self.offsetKey = offsetKey
        self.limitKey = limitKey
    }

    // MARK: - PaginationBuilder

    public var encoding: ParametersEncoding {
        return .urlQuery
    }

    public var parameters: [String : Any] {
        return [
            offsetKey ?? Constants.defaultOffsetKey: offset,
            limitKey ?? Constants.defaultLimitKey: limit
        ]
    }

    public func next(customIndexesUpdate: [String: Any] = [:]) {
        self.offset += limit
    }

    public func renew() {
        self.offset = 0
    }

}

