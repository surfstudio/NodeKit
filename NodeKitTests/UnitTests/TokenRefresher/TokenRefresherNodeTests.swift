//
//  TokenRefresherNodeThreadSafetyTests.swift
//  CoreNetKitUnitTests
//
//  Created by Александр Кравченков on 08/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation
import XCTest

@testable
import NodeKit

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
            tokenRefreshChain: tokenRefreshChainMock,
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
    
    func testProcess_thenAllResponseEmited() {
        // given
        
        let countOfRequests = 9
        var counter = 0
        
        // when
        
        let exp = self.expectation(description: "\(#function)")

        for _ in 0..<countOfRequests {
            stubNewContextTotokenRefreshChain()
            sut.processLegacy(()).onCompleted {
                counter += 1
            }
        }

        stubNewContextTotokenRefreshChain()
        sut.processLegacy(()).onCompleted {
            exp.fulfill()
        }

        self.waitForExpectations(timeout: 7, handler: nil)
        
        // then
        
        XCTAssertEqual(countOfRequests, counter)
    }

    func testProcess_thenTokenUpdateCalledOnce() {
        // given
        
        let countOfRequests = 9

        // Act

        let exp = self.expectation(description: "\(#function)")

        for _ in 0..<countOfRequests {
            stubNewContextTotokenRefreshChain()
            _ = sut.processLegacy(())
        }

        stubNewContextTotokenRefreshChain()
        sut.processLegacy(()).onCompleted {
            exp.fulfill()
        }

        self.waitForExpectations(timeout: 3, handler: nil)

        // Assert

        XCTAssertEqual(tokenRefreshChainMock.invokedProcessLegacyCount, 1)
    }
    
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
    
    private func stubNewContextTotokenRefreshChain() {
        let context = Context<Void>()
        tokenRefreshChainMock.stubbedProccessLegacyResult = context
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1)) {
            context.emit(data: ())
        }
    }
}
