//
//  LayerType.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 04/02/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// Explicit type for the transport layer.
public typealias TransportLayerNode = AsyncNode<TransportURLRequest, Json>
/// Explicit type for the request processing layer.
public typealias RequestProcessingLayerNode = AsyncNode<URLRequest, Json>
/// Explicit type for the `JSON` response processing layer.
public typealias ResponseProcessingLayerNode = AsyncNode<URLDataResponse, Json>
/// Explicit type for the post-processing layer for `JSON` response.
public typealias ResponsePostprocessorLayerNode = AsyncNode<URLProcessedResponse, Void>
