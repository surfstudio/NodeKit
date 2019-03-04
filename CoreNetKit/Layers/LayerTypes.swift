//
//  LayerType.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 04/02/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

public typealias TransportLayerNode = Node<TransportUrlRequest, Json>
public typealias RequestProcessingLayerNode = Node<RawUrlRequest, Json>
public typealias ResponseProcessingLayerNode = Node<UrlDataResponse, Json>
public typealias ResponsePostprocessorLayerNode = Node<UrlProcessedResponse, Void>
