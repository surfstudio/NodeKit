//
//  LoggingProxy.swift
//
//
//  Created by frolov on 24.12.2024.
//

import NodeKit

public class LoggingProxyMock: LoggingProxy {

    public var invokedHandle = false
    public var invokedHandleCount = 0
    public var invokedHandleParameter: LogSession?
    public var invokedHandleParameterList: [LogSession] = []

    public func handle(session: LogSession) async {
        invokedHandle = true
        invokedHandleCount += 1
        invokedHandleParameter = session
        invokedHandleParameterList.append(session)
    }

}
