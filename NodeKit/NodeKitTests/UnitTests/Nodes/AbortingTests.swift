//
//  AbortingTests.swift
//  CoreNetKitIntegrationTests
//
//  Created by Александр Кравченков on 04/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

@testable import NodeKit
@testable import NodeKitMock

import Foundation
import XCTest

final class AbortingTests: XCTestCase {
    
    // MARK: - Dependencies
    
    private var logContextMock: LoggingContextMock!
    private var aborterMock: AborterMock!
    private var nextNodeMock: AsyncNodeMock<Void, Void>!
    
    // MARK: - Sut
    
    private var sut: AborterNode<Void, Void>!
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        aborterMock = AborterMock()
        nextNodeMock = AsyncNodeMock()
        logContextMock = LoggingContextMock()
        sut = AborterNode(next: nextNodeMock, aborter: aborterMock)
    }
    
    override func tearDown() {
        super.tearDown()
        aborterMock = nil
        nextNodeMock = nil
        logContextMock = nil
        sut = nil
    }
    
    // MARK: - Tests
    
    func testAsyncAbort_whenTaskCancelBeforeProcess_thenProcessNotCalled() async {
        // when
        
        let task = Task {
            try? await Task.sleep(nanoseconds: 10_000_000)
            return await sut.process((), logContext: logContextMock)
        }
        
        task.cancel()
        let result = await task.value
    
        // then
        
        XCTAssertFalse(nextNodeMock.invokedAsyncProcess)
        switch result {
        case .success:
            XCTFail("Неожиданный результат")
        case .failure(let error):
            XCTAssertTrue(error is CancellationError)
        }
    }
    
    func testAsyncAbort_whenTaskCancelAfterProcess_thenProcessCalled_andPassedSuccess() async {
        // given
        
        nextNodeMock.stubbedAsyncProcessRunFunction = {
            try? await Task.sleep(nanoseconds: 10_000_000)
        }
        nextNodeMock.stubbedAsyncProccessResult = .success(())
        
        // when
        
        let task = Task {
            return await sut.process((), logContext: logContextMock)
        }
        
        let cancelTask = Task {
            try? await Task.sleep(nanoseconds: 5_000_000)
            task.cancel()
        }
        
        let result = await task.value
        
        await cancelTask.value
    
        // then
        
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
        XCTAssertEqual(aborterMock.invokedAsyncCancelCount, 1)
        switch result {
        case .success:
            XCTFail("Неожиданный результат")
        case .failure(let error):
            XCTAssertTrue(error is CancellationError)
        }
    }
}
