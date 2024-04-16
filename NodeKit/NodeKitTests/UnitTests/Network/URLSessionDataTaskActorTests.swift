//
//  URLSessionDataTaskActorTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 08.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit
@testable import NodeKitMock

import XCTest

final class URLSessionDataTaskActorTests: XCTestCase {
    
    // MARK: - Sut
    
    private var sut: URLSessionDataTaskActor!
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        sut = URLSessionDataTaskActor()
    }
    
    override func tearDown() {
        super.tearDown()
        sut = nil
        URLProtocolMock.flush()
    }
    
    // MARK: - Tests
    
    func testCancel_afterStore_thenTaskCancelled() async {
        // given
        
        let task = CancellableTaskMock()
        
        // when
        
        await sut.store(task: task)
        await sut.cancelTask()
        
        // then
        
        XCTAssertEqual(task.invokedCancelCount, 1)
    }
    
    func testCancel_whenCancelTwoTimes_thenTaskCancelledOnTime() async {
        // given
        
        let task = CancellableTaskMock()
        
        // when
        
        await sut.store(task: task)
        await sut.cancelTask()
        await sut.cancelTask()
        
        // then
        
        XCTAssertEqual(task.invokedCancelCount, 1)
    }
    
    func testStore_whithoutCancel_thenTaskDidNotCancell() async {
        // given
        
        let task = CancellableTaskMock()
        
        // when
        
        await sut.store(task: task)
        
        // then
        
        XCTAssertFalse(task.invokedCancel)
    }
}
