//
//  ReusableContext.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 15.10.2017.
//  Copyright © 2017 Кравченков Александр. All rights reserved.
//

import Foundation

public protocol PaginableRequestContext: ActionableContext {

    func pagin(startIndex: Int, itemsOnPage: Int)
}
