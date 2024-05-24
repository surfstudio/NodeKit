//
//  TokenRefresherNodeThreadSafetyTests.swift
//  CoreNetKitUnitTests
//
//  Created by Александр Кравченков on 08/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

@testable import NodeKit
@testable import NodeKitMock

import Foundation
import XCTest

public class TokenRefresherNodeTests: XCTestCase {
    
    // MARK: - Dependencies
    
    private var tokenRefresherActorMock: TokenRefresherActorMock!
    private var logContextMock: LoggingContextMock!
    private var tokenRefreshChainMock: AsyncNodeMock<Void, Void>!
    
    // MARK: - Sut
    
    private var sut: TokenRefresherNode!
    
    // MARK: - Lifecycle
    
    public override func setUp() {
        super.setUp()
        tokenRefresherActorMock = TokenRefresherActorMock()
        logContextMock = LoggingContextMock()
        tokenRefreshChainMock = AsyncNodeMock()
        sut = TokenRefresherNode(
            tokenRefresherActor: tokenRefresherActorMock
        )
    }
    
    public override func tearDown() {
        super.tearDown()
        tokenRefresherActorMock = nil
        logContextMock = nil
        tokenRefreshChainMock = nil
        sut = nil
    }
    
    // MARK: - Tests
    
    func testAsyncProcess_thenTokenRefresherActorCalled() async {
        // given
        
        let countOfRequests = 9
        await tokenRefresherActorMock.stub(result: .success(()))
        
        // when

        for _ in 0..<countOfRequests {
            _ = await sut.process((), logContext: logContextMock)
        }
        
        // then
        
        let refreshCount = await tokenRefresherActorMock.invokedRefreshCount
        XCTAssertEqual(refreshCount, countOfRequests)
    }
    
    func testAsyncProcess_withCancelTask_beforeStart_thenCancellationErrorReceived() async throws {
        // given
        
        await tokenRefresherActorMock.stub(result: .success(()))
        
        // when
        
        let task = Task {
            try? await Task.sleep(nanoseconds: 100 * 1000)
            return await sut.process((), logContext: LoggingContextMock())
        }
        
        task.cancel()
        
        let result = await task.value
        
        // then
        
        let error = try XCTUnwrap(result.error)
        XCTAssertTrue(error is CancellationError)
    }
    
    func testAsyncProcess_withCancelTask_afterStart_thenCancellationErrorReceived() async throws {
        // given
        
        await tokenRefresherActorMock.stub(result: .success(()))
        await tokenRefresherActorMock.stub(runFunction: {
            try? await Task.sleep(nanoseconds: 3 * 1000 * 1000)
        })
        
        // when
        
        let task = Task {
            await sut.process((), logContext: LoggingContextMock())
        }
        
        try? await Task.sleep(nanoseconds: 100 * 1000)
        
        task.cancel()
        
        let result = await task.value
        
        // then
        
        let error = try XCTUnwrap(result.error)
        XCTAssertTrue(error is CancellationError)
    }
}
