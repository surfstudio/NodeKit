//
//  LayerType.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 04/02/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

/// Явный тип для слоя обработки запроса.
public typealias RequestProcessingLayerNode = Node<URLRequest, Json>
/// Явный тип для слоя обработки ответа `JSON`
public typealias ResponseProcessingLayerNode = Node<UrlDataResponse, Json>
/// Явный тип для слоя обработки ответа `JSON`
public typealias BsonResponseProcessingLayerNode = Node<UrlDataResponse, Bson>
/// Явный тип для слоя постобработки ответа с `JSON`
public typealias ResponsePostprocessorLayerNode = Node<UrlProcessedResponse<Json>, Void>
/// Явный тип для слоя постобработки ответа с `BSON`
public typealias BsonResponsePostprocessorLayerNode = Node<UrlProcessedResponse<Bson>, Void>
