//
//  BsonLayerTypes.swift
//  NodeKit
//
//  Created by Vladislav Krupenko on 17.06.2020.
//  Copyright © 2020 Кравченков Александр. All rights reserved.
//
import Foundation

/// Явный тип для слоя обработки ответа `BSON`
public typealias BsonResponseProcessingLayerNode = Node<UrlDataResponse, Bson>
/// Явный тип для слоя постобработки ответа с `BSON`
public typealias BsonResponsePostprocessorLayerNode = Node<UrlProcessedResponse<Bson>, Void>
