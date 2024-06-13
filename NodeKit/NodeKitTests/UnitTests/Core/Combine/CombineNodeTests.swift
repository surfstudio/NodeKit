//
//  CombineNodeTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 03.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit
@testable import NodeKitMock

import Combine
import XCTest

final class CombineNodeTests: XCTestCase {
    
    // MARK: - Tests
    
    @MainActor
    func testVoidNodeResultPublisher_thenMainMethodCalled() throws {
        // given
        
        let sut = CombineCompatibleNodeMock<Void, Int>()
        sut.stubbedNodeResultPublisherResult = PassthroughSubject().eraseToAnyPublisher()
        
        // when
        
        _ = sut.nodeResultPublisher()
            .sink(receiveValue: { _ in })
        
        // then
        
        let parameters = try XCTUnwrap(sut.invokedNodeResultPublisherParameters)
        let scheduler = try XCTUnwrap(parameters.scheduler as? DispatchQueue)
        
        XCTAssertEqual(sut.invokedNodeResultPublisherCount, 1)
        XCTAssertEqual(scheduler, .main)
    }
    
    @MainActor
    func testVoidNodeResultPublisher_withCustomScheduler_thenMainMethodCalled() throws {
        // given
        
        let queue = DispatchQueue(label: "Test Process Queue")
        let sut = CombineCompatibleNodeMock<Void, Int>()
        sut.stubbedNodeResultPublisherResult = PassthroughSubject().eraseToAnyPublisher()
        
        // when
        
        _ = sut.nodeResultPublisher(on: queue)
            .sink(receiveValue: { _ in })
        
        // then
        
        let parameters = try XCTUnwrap(sut.invokedNodeResultPublisherParameters)
        let scheduler = try XCTUnwrap(parameters.scheduler as? DispatchQueue)
        
        XCTAssertEqual(sut.invokedNodeResultPublisherCount, 1)
        XCTAssertEqual(scheduler, queue)
    }
    
    @MainActor
    func testVoidNodeResultPublisher_withCustomQueue_andLogContext_thenMainMethodCalled() throws {
        // given
        
        let queue = DispatchQueue(label: "Test Process Queue")
        let sut = CombineCompatibleNodeMock<Void, Int>()
        let logContextMock = LoggingContextMock()
        
        sut.stubbedNodeResultPublisherResult = PassthroughSubject().eraseToAnyPublisher()
        
        // when
        
        _ = sut.nodeResultPublisher(on: queue, logContext: logContextMock)
            .sink(receiveValue: { _ in })
        
        // then
        
        let parameters = try XCTUnwrap(sut.invokedNodeResultPublisherParameters)
        let scheduler = try XCTUnwrap(parameters.scheduler as? DispatchQueue)
        
        XCTAssertEqual(sut.invokedNodeResultPublisherCount, 1)
        XCTAssertEqual(scheduler, queue)
        XCTAssertTrue(parameters.logContext === logContextMock)
    }
    
    @MainActor
    func testVoidNodeResultPublisher_withCustomLogContext_thenMainMethodCalled() throws {
        // given
        
        let sut = CombineCompatibleNodeMock<Void, Int>()
        let logContextMock = LoggingContextMock()
        
        sut.stubbedNodeResultPublisherResult = PassthroughSubject().eraseToAnyPublisher()
        
        // when
        
        _ = sut.nodeResultPublisher(logContext: logContextMock)
            .sink(receiveValue: { _ in })
        
        // then
        
        let parameters = try XCTUnwrap(sut.invokedNodeResultPublisherParameters)
        let scheduler = try XCTUnwrap(parameters.scheduler as? DispatchQueue)
        
        XCTAssertEqual(sut.invokedNodeResultPublisherCount, 1)
        XCTAssertEqual(scheduler, .main)
        XCTAssertTrue(parameters.logContext === logContextMock)
    }
    
    @MainActor
    func testNodeResultPublisher_withData_thenMainMethodCalled() throws {
        // given
        
        let sut = CombineCompatibleNodeMock<Int, Int>()
        let expectedInput = 1
        
        sut.stubbedNodeResultPublisherResult = PassthroughSubject().eraseToAnyPublisher()
        
        // when
        
        _ = sut.nodeResultPublisher(for: expectedInput)
            .sink(receiveValue: { _ in })
        
        // then
        
        let parameters = try XCTUnwrap(sut.invokedNodeResultPublisherParameters)
        let scheduler = try XCTUnwrap(parameters.scheduler as? DispatchQueue)
        
        XCTAssertEqual(sut.invokedNodeResultPublisherCount, 1)
        XCTAssertEqual(parameters.input, expectedInput)
        XCTAssertEqual(scheduler, .main)
    }
    
    func testNodeResultPublisher_withData_onCustomQueue_thenMainMethodCalled() throws {
        // given
        
        let sut = CombineCompatibleNodeMock<Int, Int>()
        let expectedInput = 1
        let queue = DispatchQueue(label: "Test Process Queue")
        
        sut.stubbedNodeResultPublisherResult = PassthroughSubject().eraseToAnyPublisher()
        
        // when
        
        _ = sut.nodeResultPublisher(for: expectedInput, on: queue)
            .sink(receiveValue: { _ in })
        
        // then
        
        let parameters = try XCTUnwrap(sut.invokedNodeResultPublisherParameters)
        let scheduler = try XCTUnwrap(parameters.scheduler as? DispatchQueue)
        
        XCTAssertEqual(sut.invokedNodeResultPublisherCount, 1)
        XCTAssertEqual(parameters.input, expectedInput)
        XCTAssertEqual(scheduler, queue)
    }
    
    @MainActor
    func testNodeResultPublisher_withData_andLogContext_thenMainMethodCalled() throws {
        // given
        
        let sut = CombineCompatibleNodeMock<Int, Int>()
        let logContextMock = LoggingContextMock()
        let expectedInput = 3
        
        sut.stubbedNodeResultPublisherResult = PassthroughSubject().eraseToAnyPublisher()
        
        // when
        
        _ = sut.nodeResultPublisher(for: expectedInput, logContext: logContextMock)
            .sink(receiveValue: { _ in })
        
        // then
        
        let parameters = try XCTUnwrap(sut.invokedNodeResultPublisherParameters)
        let scheduler = try XCTUnwrap(parameters.scheduler as? DispatchQueue)
        
        XCTAssertEqual(sut.invokedNodeResultPublisherCount, 1)
        XCTAssertEqual(parameters.input, expectedInput)
        XCTAssertEqual(scheduler, .main)
        XCTAssertTrue(parameters.logContext === logContextMock)
    }
}
