//
//  ReusableContext.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 15.10.2017.
//  Copyright © 2017 Кравченков Александр. All rights reserved.
//

import Foundation

/// This context provide interface for pagination.
/// It means that specific implementation of this context should incapsulate all pagination logic
public protocol PaginableRequestContextProtocol: ActionableContextProtocol {

    func pagin(startIndex: Int, itemsOnPage: Int)
}
