//
//  CoreServerRequest.swift
//  CoreNetKit
//
//  Created by Alexander Kravchenkov on 15.12.17.
//  Copyright © 2017 Кравченков Александр. All rights reserved.
//

import Foundation

public protocol CoreServerRequest {
    func perform(with completion: @escaping (CoreServerResponse) -> Void)
    func cancel()
}
