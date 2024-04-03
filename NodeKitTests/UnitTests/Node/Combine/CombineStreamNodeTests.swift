//
//  CombineStreamNodeTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 03.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import Combine
import XCTest

final class CombineStreamNodeTests: XCTestCase {
    
    // MARK: - Tests
    
    func testProcess_withVoid_thenMainMethodCalled() {
        // given
        
        let sut = CombineStreamNodeMock<Void, Int>()
        
        // when
        
        sut.process()
        
        // then
        
        XCTAssertEqual(sut.invokedProcessCount, 1)
    }
    
    func testProcess_withData_thenMainMethodCalled() {
        // given
        
        let sut = CombineStreamNodeMock<Int, Int>()
        let expectedInput = 15
        
        // when
        
        sut.process(expectedInput)
        
        // then
        
        XCTAssertEqual(sut.invokedProcessCount, 1)
        XCTAssertEqual(sut.invokedProcessParameters?.0, expectedInput)
    }
    
    func testNodeResultPublisher_thenMainMethodCalled() throws {
        // given
        
        let sut = CombineStreamNodeMock<Int, Int>()
        
        sut.stubbedNodeResultPublisherResult = PassthroughSubject().eraseToAnyPublisher()
        
        // when
        
        _ = sut.nodeResultPublisher
        
        // then
        
        let parameter = try XCTUnwrap(sut.invokedNodeResultPublisherParameter)
        let scheduler = try XCTUnwrap(parameter as? DispatchQueue)
        
        XCTAssertEqual(sut.invokedNodeResultPublisherCount, 1)
        XCTAssertEqual(scheduler, .main)
    }
}
