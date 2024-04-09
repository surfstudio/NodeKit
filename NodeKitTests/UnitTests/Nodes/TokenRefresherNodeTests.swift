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
}
