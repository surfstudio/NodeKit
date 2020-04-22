//
//  PaginationModel.swift
//  NodeKit
//
//  Created by Alena Belyaeva on 22.04.2020.
//  Copyright © 2020 Кравченков Александр. All rights reserved.
//

import Foundation

public protocol PaginationModel {

    /// This parameter check where parameters should go - query or body
    var encoding: ParametersEncoding { get }

    /// Parameters for pagination request
    var parameters: [String: Any] { get }

    /// This metnod alows 
    func next(customIndexesUpdate: [String: Any])

    /// This method allows to restart paging from start point
    func renew()

}
