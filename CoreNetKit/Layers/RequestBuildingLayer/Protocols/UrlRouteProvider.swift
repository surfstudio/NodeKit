//
//  UrlProvider.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 05/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

public protocol UrlRouteProvider {
    func url() throws -> URL
}
