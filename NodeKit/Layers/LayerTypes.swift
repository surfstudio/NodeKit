//
//  LayerType.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 04/02/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

/// Явный тип для слоя транспорта.
public typealias TransportLayerNode = Node<TransportUrlRequest, Json>
/// Явный тип для слоя обработки запроса.
public typealias RequestProcessingLayerNode = Node<RawUrlRequest, Json>
/// Явный тип для слоя обработки ответа.
public typealias ResponseProcessingLayerNode = Node<UrlDataResponse, Json>
/// Явный тип для слоя постобработки ответа.
public typealias ResponsePostprocessorLayerNode = Node<UrlProcessedResponse, Void>
