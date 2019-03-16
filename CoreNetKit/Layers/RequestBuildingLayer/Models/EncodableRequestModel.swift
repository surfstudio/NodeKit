//
//  EncodableRequestModel.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 05/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// Модель за проса в сеть.
/// Является промежуточным представлением использующимся на 
/// Является следующим этапом после `RoutableRequestModel`
/// В дальнейшем ковнертируется в `EncodableRequestModel`
///
/// - SeeAlso:
///     - `RoutableRequestModel`
///     - `EncodableRequestModel`
public struct EncodableRequestModel<Route, Raw, Encoding> {
    public var metadata: [String: String]
    public var raw: Raw
    public var route: Route
    public var encoding: Encoding
}
