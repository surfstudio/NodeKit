//
//  DTOMapperNodeTests.swift
//  IntegrationTests
//
//  Created by Aleksandr Smirnov on 22.10.2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation
import XCTest

@testable
import NodeKit

class DTOMapperNodeTests: XCTestCase {
    
    class CorruptedStub: Node<Json, Json> {
        
        let stubJson: Json = [
            "id": "1",
            "name": "Francisco", // corrupted key
            "lastName": "D'Anconia"
        ]
        
        @discardableResult
        public override func process(_ data: Json) -> Observer<Json> {
            return .emit(data: stubJson)
        }
    }
    
    class CorrectStub: Node<Json, Json> {
        
        let stubJson: Json = [
            "id": "1",
            "firstName": "Francisco",
            "lastName": "D'Anconia"
        ]
        
        @discardableResult
        public override func process(_ data: Json) -> Observer<Json> {
            return .emit(data: stubJson)
        }
    }

    func testThatCodableErrorLoggingCorrectly() {
        let nextNode = CorruptedStub()
        let mapperNode = DTOMapperNode<Json, UserEntry>(next: nextNode)
        
        var resultError: Error?
        
        let exp = self.expectation(description: "\(#function)")
        
        let result = mapperNode.process([:]).onError { error in
            resultError = error
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 3, handler: nil)

        XCTAssertNotNil(result.log)
        XCTAssertNotNil(resultError)
        
        let codableError = resultError as? Swift.DecodingError
        let logMessageId = result.log?.id
        
        XCTAssertNotNil(codableError)
        XCTAssertNotNil(logMessageId)
        XCTAssert(logMessageId!.contains(mapperNode.objectName))
    }
    
    func testThatSuccessCaseNotLogging() {
        let nextNode = CorrectStub()
        let mapperNode = DTOMapperNode<Json, UserEntry>(next: nextNode)
        
        var resultUser: UserEntry?
        var resultError: Error?
        
        let exp = self.expectation(description: "\(#function)")
        
        let result = mapperNode.process([:])
            .onCompleted { user in
                resultUser = user
                exp.fulfill()
            }
            .onError { error in
                resultError = error
                exp.fulfill()
            }
        
        waitForExpectations(timeout: 3, handler: nil)

        XCTAssertNotNil(resultUser)
        XCTAssertNil(resultError)
        XCTAssertNil(result.log)
    }
}
