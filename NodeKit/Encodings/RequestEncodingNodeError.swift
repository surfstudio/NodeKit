//
//  RequestEncodingNodeError.swift
//  NodeKit
//
//  Created by Vladislav Krupenko on 17.06.2020.
//  Copyright © 2020 Кравченков Александр. All rights reserved.
//

import Foundation

enum RequestEncodingNodeError: Error {
    case unsupportedDataType
    case missedJsonEncodingType
}
