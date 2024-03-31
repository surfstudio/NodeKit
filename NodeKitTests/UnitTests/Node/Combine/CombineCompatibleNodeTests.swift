//
//  CombineCompatibleNodeTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 29.03.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit
import Combine
import XCTest

final class CombineCompatibleNodeTests: XCTestCase {
    
    // MARK: - Dependencies
    
    private var adapterMock: NodeAdapterMock<Int, Int>!
    private var logContext: LoggingContextMock!
    private var cancellable: Set<AnyCancellable>!
    
    // MARK: - Sut
    
    private var sut: CombineCompatibleNode<Int, Int>!
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        adapterMock = NodeAdapterMock()
        cancellable = Set()
        logContext = LoggingContextMock()
        sut = CombineCompatibleNode(adapter: adapterMock)
    }
    
    override func tearDown() {
        super.tearDown()
        adapterMock = nil
        cancellable = nil
        logContext = nil
        sut = nil
    }
    
    // MARK: - Tests
    
    func testProcess_withoutLogContext_thenAdapterCalled() async {
        // given
        
        let expectation = expectation(description: "Method call")
        let expectedInput = 2
        
        adapterMock.stubbedAsyncProcessRunFunction = {
            expectation.fulfill()
        }
        
        // when
        
        Task {
            sut.process(data: expectedInput)
        }
        
        await fulfillment(of: [expectation], timeout: 0.1)
        
        // then
        
        XCTAssertEqual(adapterMock.invokedProcessCount, 1)
        XCTAssertEqual(adapterMock.invokedProcessParameters?.data, expectedInput)
        XCTAssertTrue(adapterMock.invokedProcessParameters?.output as? CombineCompatibleNode<Int, Int> === sut)
    }
    
    func testProcess_withLogContext_thenAdapterCalled() async {
        // given
        
        let expectation = expectation(description: "Method call")
        let expectedInput = 3
        
        adapterMock.stubbedAsyncProcessRunFunction = {
            expectation.fulfill()
        }
        
        // when
        
        Task {
            sut.process(data: expectedInput, logContext: logContext)
        }
        
        await fulfillment(of: [expectation], timeout: 0.1)
        
        // then
        
        XCTAssertEqual(adapterMock.invokedProcessCount, 1)
        XCTAssertEqual(adapterMock.invokedProcessParameters?.data, expectedInput)
        XCTAssertTrue(adapterMock.invokedProcessParameters?.logContext === logContext)
        XCTAssertTrue(adapterMock.invokedProcessParameters?.output as? CombineCompatibleNode<Int, Int> === sut)
    }
    
    func testSend_whenSuccess_thenSuccessResultReceived() async throws {
        // given
        
        let expectation = expectation(description: "result")
        let expectedResult = 10
        
        var result: NodeResult<Int>?
        var invokedCompletion = false
        
        // when
        
        sut.send(.success(10))
        sut.eraseToAnyPublisher()
            .sink(receiveCompletion: { _ in
                invokedCompletion = true
            }, receiveValue: { value in
                result = value
                expectation.fulfill()
            })
            .store(in: &cancellable)
        
        await fulfillment(of: [expectation], timeout: 0.3)
        
        // then
        
        let unwrappedResult = try XCTUnwrap(result)
        
        XCTAssertFalse(invokedCompletion)
        
        switch unwrappedResult {
        case .success(let value):
            XCTAssertEqual(value, expectedResult)
        case .failure:
            XCTFail("Неверный результат работы метода")
        }
    }
    
    func testSend_whenFailure_thenFailureResultReceived() async throws {
        // given
        
        let expectation = expectation(description: "result")
        
        var result: NodeResult<Int>?
        var invokedCompletion = false
        
        // when
        
        sut.send(.failure(MockError.thirdError))
        sut.eraseToAnyPublisher()
            .sink(receiveCompletion: { _ in
                invokedCompletion = true
            }, receiveValue: { value in
                result = value
                expectation.fulfill()
            })
            .store(in: &cancellable)
        
        await fulfillment(of: [expectation], timeout: 0.3)
        
        // then
        
        let unwrappedResult = try XCTUnwrap(result)
        
        XCTAssertFalse(invokedCompletion)
        
        switch unwrappedResult {
        case .success:
            XCTFail("Неверный результат работы метода")
        case .failure(let error):
            let unwrappedError = try XCTUnwrap(error as? MockError)
            XCTAssertEqual(unwrappedError, .thirdError)
        }
    }
    
    @MainActor
    func testSend_whenMultipleSubscribers_thenDataSent() async throws {
        // given
        
        let expectation1 = expectation(description: "result1")
        let expectation2 = expectation(description: "result2")
        let expectation3 = expectation(description: "result3")
        let expectedResults: [Result<Int, MockError>] = [
            .success(22),
            .failure(MockError.firstError),
            .success(21),
            .failure(MockError.secondError)
        ]
        let nodeStub: [NodeResult<Int>] = expectedResults.map { res in res.mapError { $0 } }
        
        var invokedCompletion = false
        var firstResults: [NodeResult<Int>] = []
        var secondResults: [NodeResult<Int>] = []
        var thirdResults: [NodeResult<Int>] = []
        
        // when
        
        sut.eraseToAnyPublisher()
            .sink(receiveCompletion: { _ in
                invokedCompletion = true
            }, receiveValue: { value in
                firstResults.append(value)
                if firstResults.count == expectedResults.count {
                    expectation1.fulfill()
                }
            })
            .store(in: &cancellable)
        
        sut.eraseToAnyPublisher()
            .sink(receiveCompletion: { _ in
                invokedCompletion = true
            }, receiveValue: { value in
                secondResults.append(value)
                if secondResults.count == expectedResults.count {
                    expectation2.fulfill()
                }
            })
            .store(in: &cancellable)
        
        nodeStub.forEach { sut.send($0) }
        
        await Task {
            try? await Task.sleep(nanoseconds: 100000000)
            sut.eraseToAnyPublisher()
                .sink(receiveCompletion: { _ in
                    invokedCompletion = true
                }, receiveValue: { value in
                    thirdResults.append(value)
                    expectation3.fulfill()
                })
                .store(in: &cancellable)
        }.value
        
        await fulfillment(of: [expectation1, expectation2, expectation3], timeout: 0.3)
        
        // then
        
        let firstCastedResult = firstResults.compactMap { $0.castToMockError() }
        let secondCastedResult = secondResults.compactMap { $0.castToMockError() }
        let thirdCastedResult = thirdResults.compactMap { $0.castToMockError() }
        
        XCTAssertFalse(invokedCompletion)
        XCTAssertEqual(firstCastedResult, expectedResults)
        XCTAssertEqual(secondCastedResult, expectedResults)
        XCTAssertEqual(thirdCastedResult, [.failure(MockError.secondError)])
    }
    
    func testEraseToAnyPublisher_withCustomQueue_thenQueueChanged() async {
        // given
        
        let expectation = expectation(description: "result")
        let expectedLabel = "Test Queue"
        let expectedQueue = DispatchQueue(label: expectedLabel)
        
        var currentThread: Thread?
        var dispatchQueueLabel: String?
        
        // when
        
        sut.send(.success(10))
        sut.eraseToAnyPublisher(queue: expectedQueue)
            .sink(receiveValue: { value in
                currentThread = Thread.current
                dispatchQueueLabel = DispatchQueue.currentLabel
                expectation.fulfill()
            })
            .store(in: &cancellable)
        
        await fulfillment(of: [expectation], timeout: 0.3)
        
        // then
        
        XCTAssertEqual(currentThread?.isMainThread, false)
        XCTAssertEqual(dispatchQueueLabel, expectedLabel)
    }
}
