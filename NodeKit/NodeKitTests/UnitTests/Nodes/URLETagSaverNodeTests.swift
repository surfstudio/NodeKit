//
//  URLETagSaverNodeTests.swift
//  CoreNetKitUnitTests
//
//  Created by Александр Кравченков on 05/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

@testable import NodeKit
@testable import NodeKitMock

import Foundation
import XCTest

final class URLETagSaverNodeTests: XCTestCase {
    
    // MARK: - Tests
    
    func testAsyncProcess_whenHasTag_thenNodeSaveTag() async throws {
        // given

        let sut = URLETagSaverNode(next: nil)
        let url = URL(string: "http://urletagsaver.tests/testNodeSaveTag")!
        let tag = "\(NSObject().hash)"
        let data = Utils.getMockURLProcessedResponse(url: url, headers: [ETagConstants.eTagResponseHeaderKey: tag])

        defer {
            UserDefaults.etagStorage?.removeObject(forKey: url.absoluteString)
        }

        // when
        
        let result = await sut.process(data, logContext: LoggingContextMock())
        let readedTag = UserDefaults.etagStorage?.string(forKey: url.absoluteString)

        // then
        
        let unwrappedTag = try XCTUnwrap(readedTag)

        XCTAssertNotNil(result.value)
        XCTAssertEqual(unwrappedTag, tag)
    }

    func testAsyncProcess_withoutTag_thenNodeNotSaveTag() async {
        // given

        let sut = URLETagSaverNode(next: nil)
        let url = URL(string: "http://urletagsaver.tests/testNodeNotSaveTag")!
        let data = Utils.getMockURLProcessedResponse(url: url)

        defer {
            UserDefaults.etagStorage?.removeObject(forKey: url.absoluteString)
        }

        // when
        
        let result = await sut.process(data, logContext: LoggingContextMock())
        let readedTag = UserDefaults.etagStorage?.string(forKey: url.absoluteString)

        // then

        XCTAssertNotNil(result.value)
        XCTAssertNil(readedTag)
    }

    func testAsyncProcess_withCustomKey_thenTagSaved() async throws {
        // given
        
        let url = URL(string: "http://urletagsaver.tests/testSaveWorkForCustomKey")!
        let tag = "\(NSObject().hash)"
        let tagKey = "My-Custom-ETag-Key"
        let sut = URLETagSaverNode(next: nil, eTagHeaderKey: tagKey)
        let data = Utils.getMockURLProcessedResponse(url: url, headers: [tagKey: tag])

        defer {
            UserDefaults.etagStorage?.removeObject(forKey: url.absoluteString)
        }

        // when

        let result = await sut.process(data, logContext: LoggingContextMock())
        let readedTag = UserDefaults.etagStorage?.string(forKey: url.absoluteString)

        // then
        
        let unwrappedTag = try XCTUnwrap(readedTag)

        XCTAssertNotNil(result.value)
        XCTAssertEqual(unwrappedTag, tag)
    }

    /// Проверяет что при сохранении данных от двух одинаковых запросов с разным порядком ключей
    /// Будет создана только одна запись
    func testAsyncProcess_whenSaveDataForTwoSameRequestsWithDifferentOrderOfKeys_thenOnlyOneSaved() async throws {
        // given

        let url1 = URL(string: "http://urletagsaver.tests/test?q1=1&q2=2")!
        let url2 = URL(string: "http://urletagsaver.tests/test?q2=2&q1=1")!
        let tag = "\(NSObject().hash)"
        let headers = [ETagConstants.eTagResponseHeaderKey: tag]
        let sut = URLETagSaverNode(next: nil)
        let data1 = Utils.getMockURLProcessedResponse(url: url1, headers: headers)
        let data2 = Utils.getMockURLProcessedResponse(url: url2, headers: headers)

        defer {
            UserDefaults.etagStorage?.removeObject(forKey: url1.absoluteString)
            UserDefaults.etagStorage?.removeObject(forKey: url2.absoluteString)
        }

        // when
        
        _ = await sut.process(data1, logContext: LoggingContextMock())
        _ = await sut.process(data2, logContext: LoggingContextMock())
        
        let firstTag = UserDefaults.etagStorage?.string(forKey: url1.absoluteString)
        let secondTag = UserDefaults.etagStorage?.string(forKey: url2.absoluteString)
        let savedTag = UserDefaults.etagStorage?.string(forKey: url1.withOrderedQuery()!)

        // then

        XCTAssertEqual(savedTag, tag)
        XCTAssertNil(firstTag)
        XCTAssertNil(secondTag)
    }
    
    func testAsyncProcess_withCancelTask_beforeStart_thenCancellationErrorReceived() async throws {
        // given
        
        let url = URL(string: "http://urletagsaver.tests/testSaveWorkForCustomKey")!
        let nextNode = AsyncNodeMock<URLProcessedResponse, Void>()
        let sut = URLETagSaverNode(next: nextNode)
        let data = Utils.getMockURLProcessedResponse(url: url, headers: [:])
        
        nextNode.stubbedAsyncProccessResult = .success(())
        
        // when
        
        let task = Task {
            try? await Task.sleep(nanoseconds: 100 * 1000)
            return await sut.process(data, logContext: LoggingContextMock())
        }
        
        task.cancel()
        
        let result = await task.value
        
        // then
        
        let error = try XCTUnwrap(result.error)
        XCTAssertTrue(error is CancellationError)
    }
    
    func testAsyncProcess_withCancelTask_afterStart_thenCancellationErrorReceived() async throws {
        // given
        
        let url = URL(string: "http://urletagsaver.tests/testSaveWorkForCustomKey")!
        let nextNode = AsyncNodeMock<URLProcessedResponse, Void>()
        let sut = URLETagSaverNode(next: nextNode)
        let data = Utils.getMockURLProcessedResponse(url: url, headers: [:])
        
        nextNode.stubbedAsyncProcessRunFunction = {
            try? await Task.sleep(nanoseconds: 3 * 1000 * 1000)
        }
        nextNode.stubbedAsyncProccessResult = .success(())
        
        // when
        
        let task = Task {
            await sut.process(data, logContext: LoggingContextMock())
        }
        
        try? await Task.sleep(nanoseconds: 100 * 1000)
        
        task.cancel()
        
        let result = await task.value
        
        // then
        
        let error = try XCTUnwrap(result.error)
        XCTAssertTrue(error is CancellationError)
    }
}
