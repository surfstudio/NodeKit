//
//  CombineNodeTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 03.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import Combine
import XCTest

final class CombineNodeTests: XCTestCase {
    
    // MARK: - Tests
    
    func testNodeResultPublisher_withVoid_thenMainMethodCalled() throws {
        // given
        
        let sut = CombineNodeMock<Void, Int>()
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
    
    func testNodeResultPublisher_withData_thenMainMethodCalled() throws {
        // given
        
        let sut = CombineNodeMock<Int, Int>()
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
        
        let sut = CombineNodeMock<Int, Int>()
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
    
    func testNodeResultPublisher_withData_andLogContext_thenMainMethodCalled() throws {
        // given
        
        let sut = CombineNodeMock<Int, Int>()
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
