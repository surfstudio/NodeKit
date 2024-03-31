//
//  NodeAdapterMock.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 31.03.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit

final class NodeAdapterMock<Input, Output>: NodeAdapter {
    
    struct Parameters {
        let data: Input
        let logContext: LoggingContextProtocol
        let output: any NodeAdapterOutput<Output>
    }
    
    var invokedProcess = false
    var invokedProcessCount = 0
    var invokedProcessParameters: Parameters?
    var stubbedAsyncProcessRunFunction: (() async -> Void)?
    var inbokedProcessParametersList: [Parameters] = []
    
    func process(
        data: Input,
        logContext: LoggingContextProtocol,
        output: some NodeAdapterOutput<Output>
    ) async {
        invokedProcess = true
        invokedProcessCount += 1
        invokedProcessParameters = Parameters(data: data, logContext: logContext, output: output)
        inbokedProcessParametersList.append(Parameters(data: data, logContext: logContext, output: output))
        if let function = stubbedAsyncProcessRunFunction {
            await function()
        }
    }
}
