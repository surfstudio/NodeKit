//
//  TokenRefresherActorTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 22.03.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import XCTest
@testable import NodeKit

final class TokenRefresherActorTests: XCTestCase {
    
    // MARK: - Dependencies
    
    private var logContextMock: LoggingContextMock!
    private var tokenRefreshChain: AsyncNodeMock<Void, Void>!
    
    // MARK: - Sut
    
    private var sut: TokenRefresherActor!
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        logContextMock = LoggingContextMock()
        tokenRefreshChain = AsyncNodeMock()
        sut = TokenRefresherActor(tokenRefreshChain: tokenRefreshChain)
    }
    
    override func tearDown() {
        logContextMock = nil
        tokenRefreshChain = nil
        sut = nil
    }
    
    // MARK: - Tests
    
    func testRefresh_thenProcessCalledOnce() async {
        // given
        
        tokenRefreshChain.stubbedAsyncProccessResult = .success(())
        tokenRefreshChain.stubbedAsyncProcessRunFunction = {
            try? await Task.sleep(nanoseconds: 10_000_000)
        }
        
        // when
        
        let task1 = Task {
            await sut.refresh(logContext: logContextMock)
        }
        
        let task2 = Task {
            await sut.refresh(logContext: logContextMock)
        }
        
        let task3 = Task {
            await sut.refresh(logContext: logContextMock)
        }
        
        
        // then
        
        let values = await [task1.value, task2.value, task3.value]
        XCTAssertEqual(values.count, 3)
        XCTAssertEqual(tokenRefreshChain.invokedAsyncProcessCount, 1)
    }
}
