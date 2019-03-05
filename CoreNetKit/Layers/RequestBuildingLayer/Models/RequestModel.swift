//
//  RequestModel.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 05/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

public struct RequestModel<Raw> {
    public var metadata: [String: String]
    public var raw: Raw
}
