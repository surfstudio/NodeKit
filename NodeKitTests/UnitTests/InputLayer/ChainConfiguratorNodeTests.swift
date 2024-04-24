//
//  ChainConfiguratorNodeTests.swift
//  CoreNetKitUnitTests
//
//  Created by Александр Кравченков on 08/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation
import XCTest

@testable
import NodeKit

final class ChainConfiguratorNodeTests: XCTestCase {
    
    // MARK: - Dependencies
    
    private var nextNodeMock: AsyncNodeMock<Void, Void>!
    private var logContextMock: LoggingContextMock!

    // MARK: - Sut
    
    private var sut: ChainConfiguratorNode<Void, Void>!
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        nextNodeMock = AsyncNodeMock()
        logContextMock = LoggingContextMock()
        sut = ChainConfiguratorNode(next: nextNodeMock)
    }
    
    override func tearDown() {
        super.tearDown()
        nextNodeMock = nil
        logContextMock = nil
        sut = nil
    }


    public func testNextNodeDispatchedInBackground() {
        // given
        
        var queueLabel: String?
        
        nextNodeMock.stubbedProccessLegacyResult = .emit(data: ())
        nextNodeMock.stubbedProcessLegacyRunFunction = {
            queueLabel = DispatchQueue.currentLabel
        }

        // when

        let exp = self.expectation(description: "\(#function)")

        _ = sut.processLegacy(()).onCompleted {
            exp.fulfill()
        }

        self.waitForExpectations(timeout: 2, handler: nil)

        // then

        XCTAssertEqual(queueLabel, "com.apple.root.user-initiated-qos")
    }

    public func testNextNodeDispatchedInMain() {

        // given

        var currentQueueLabel = ""
        
        nextNodeMock.stubbedProccessLegacyResult = .emit(data: ())

        // Act

        let exp = self.expectation(description: "\(#function)")

        _ = sut.processLegacy(()).onCompleted {
            currentQueueLabel = DispatchQueue.currentLabel
            exp.fulfill()
        }

        self.waitForExpectations(timeout: 2, handler: nil)

        // Assert

        XCTAssertEqual(currentQueueLabel, "com.apple.main-thread")
    }
    
    func testAsyncProcess_withMainBeginQueue_thenTaskStartedOnMainThread() async throws {
        // given
    
        nextNodeMock.stubbedAsyncProccessResult = .success(())
        
        // when
        
        _ = await sut.process((), logContext: logContextMock)
        
        // then
        
        XCTAssertEqual(nextNodeMock.invokedAsyncProcessCount, 1)
    }
}
