//
//  URLProvider.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 05/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// Protocol for URL route provider
public protocol URLRouteProvider {

    /// Returns URL
    ///
    /// - Returns: The URL route of this object
    /// - Throws: May throw an exception if the object's state does not allow returning the route.
    func url() throws -> URL
}
