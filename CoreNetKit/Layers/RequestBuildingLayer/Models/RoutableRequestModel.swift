//
//  RoutableRequestModel.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 05/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

public struct RoutableRequestModel<Route, Raw> {
    public var metadata: [String: String]
    public var raw: Raw
    public var route: Route
}
