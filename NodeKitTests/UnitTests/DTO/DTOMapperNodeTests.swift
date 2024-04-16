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
    
    class StubNode: AsyncNode {
        let json: Json
        let resultError: Error?
        
        init(json: Json, resultError: Error? = nil) {
            self.json = json
            self.resultError = resultError
        }
        
        @discardableResult
        public func process(_ data: Json) -> Observer<Json> {
            if let error = resultError {
                var log = Log(self.logViewObjectName, id: self.objectName, order: LogOrder.dtoMapperNode)
                log += "\(error)"
                return Context<Json>().log(log).emit(error: error)
            }
            return .emit(data: json)
        }
        
        func process(
            _ data: Json,
            logContext: LoggingContextProtocol
        ) async -> NodeResult<Json> {
            return .success(json)
        }
    }

    func testThatCodableErrorLoggingCorrectly() {
        let nextNode = StubNode(json: [
            "id": "1",
            "name": "Francisco", // corrupted key
            "lastName": "D'Anconia"
        ])
        
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
        let nextNode = StubNode(json: [
            "id": "1",
            "firstName": "Francisco",
            "lastName": "D'Anconia"
        ])
        
        let mapperNode = DTOMapperNode<Json, UserEntry>(next: nextNode)
        
        var resultUser: UserEntry?
        var resultError: Error?
        
        let exp = self.expectation(description: "\(#function)")
        
        let result = mapperNode.process([:]).onCompleted { user in
            resultUser = user
            exp.fulfill()
        }.onError { error in
            resultError = error
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 3, handler: nil)

        XCTAssertNotNil(resultUser)
        XCTAssertNil(resultError)
        XCTAssertNil(result.log)
    }
    
    func testThatCodableErrorNotLoggingInsteadOtherError() {
        let nextNode = StubNode(json: [:], resultError: BaseTechnicalError.noInternetConnection)
        
        let mapperNode = DTOMapperNode<Json, UserEntry>(next: nextNode)
        
        var resultError: Error?
        
        let exp = self.expectation(description: "\(#function)")
        
        let result = mapperNode.process([:]).onError { error in
            resultError = error
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 3, handler: nil)

        XCTAssertNotNil(resultError)
        XCTAssertNotNil(result.log)
        
        let error = resultError as? BaseTechnicalError
        let logMessageId = result.log?.id

        XCTAssertNotNil(error)
        XCTAssertNotNil(logMessageId)
        XCTAssertFalse(logMessageId!.contains(mapperNode.objectName))
        XCTAssert(logMessageId!.contains(nextNode.objectName))
    }
}
