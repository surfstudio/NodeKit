//
//  EncodableRequestModel.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 05/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// Model for network request.
/// It serves as a generalized representation of any request.
/// It is the next stage after ``RoutableRequestModel``
public struct EncodableRequestModel<Route, Raw, Encoding> {
    /// Metadata
    public var metadata: [String: String]
    /// Data for the request in Raw
    public var raw: Raw
    /// Route to the remote method
    public var route: Route
    /// Request data encoding
    public var encoding: Encoding?
}
