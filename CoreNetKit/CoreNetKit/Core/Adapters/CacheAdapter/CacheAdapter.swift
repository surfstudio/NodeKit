//
//  CacheAdapter.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 15.10.2017.
//  Copyright © 2017 Кравченков Александр. All rights reserved.
//

import Foundation

public protocol CacheAdapter {

    func save(urlResponse: URLResponse, urlRequest: URLRequest, data: Data)

    func load(urlRequest: URLRequest, response: CoreServerResponse?) -> CoreServerResponse
}
