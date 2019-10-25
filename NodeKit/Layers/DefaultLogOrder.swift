//
//  DefaultLogOrder.swift
//  NodeKit
//
//  Created by Александр Кравченков on 14/06/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

public enum LogOrder {
    
    public static let voidIONode = 20.0
    public static let voidOutputNode = 25.0

    public static let requestCreatorNode = 40.0
    public static let requestSenderNode = 49.0

    public static let responseProcessorNode = 50.0
    public static let responseDataPreprocessorNode = 55.0

    public static let responseHttpErrorProcessorNode = 57.0

    public static let responseDataParserNode = 59.0
    
    public static let dtoMapperNode = 100.0
}
