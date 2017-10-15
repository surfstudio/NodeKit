//
//  ReusablePagingRequest.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 15.10.2017.
//  Copyright © 2017 Кравченков Александр. All rights reserved.
//

import Foundation

public protocol ReusablePagingRequest {

    func reuse(startIndex: Int, itemsOnPage: Int)

}
