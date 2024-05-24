//
//  LayerType.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 04/02/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// Явный тип для слоя транспорта.
public typealias TransportLayerNode = AsyncNode<TransportURLRequest, Json>
/// Явный тип для слоя обработки запроса.
public typealias RequestProcessingLayerNode = AsyncNode<URLRequest, Json>
/// Явный тип для слоя обработки ответа `JSON`
public typealias ResponseProcessingLayerNode = AsyncNode<URLDataResponse, Json>
/// Явный тип для слоя постобработки ответа с `JSON`
public typealias ResponsePostprocessorLayerNode = AsyncNode<URLProcessedResponse, Void>
