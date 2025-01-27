//
//  MultipartRequestTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 09.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit
@testable import NodeKitMock

import Foundation
import XCTest

final class MultipartRequestTests: XCTestCase {
    
    // MARK: - Nested Types

    struct TestData: DTOConvertible, RawMappable {

        typealias DTO = TestData

        typealias Raw = [String: Data]

        let data: [String: Data]

        func toDTO() throws -> MultipartRequestTests.TestData {
            return self
        }

        func toRaw() throws -> [String : Data] {
            return self.data
        }

        static func from(dto: MultipartRequestTests.TestData) throws -> MultipartRequestTests.TestData {
            return .init(data: dto.data)
        }

        static func from(raw: [String : Data]) throws -> MultipartRequestTests.TestData {
            return .init(data: raw)
        }
    }
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        URLResponsesStub.stubIntegrationTestsResponses()
    }
    
    override func tearDown() {
        super.tearDown()
        URLResponsesStub.flush()
    }
    
    // MARK: - Tests

    func testMultipartPing() async throws {
        // given

        let data = TestData(data: [
            "file1": Data(),
            "file2": Data(),
            "file3": Data(),
        ])
        
        let model = MultipartModel(payloadModel: data)
        let chainsBuilder = URLChainBuilder<Routes>(serviceChainProvider: URLServiceChainProviderMock())

        // when

        let result: NodeResult<Json> = await chainsBuilder
            .route(.post, .multipartPing)
            .build()
            .process(model)

        // then
        
        let value = try XCTUnwrap(result.value as? [String: Bool])

        XCTAssertEqual(value, ["success": true])
    }

    func testValuesSendsCorrectly() async throws {
        // given

        let data = TestData(data: [
            "word1": "Test".data(using: .utf8)!,
            "word2": "Success".data(using: .utf8)!,
        ])
        
        let model = MultipartModel(payloadModel: data)
        let chainsBuilder = URLChainBuilder<Routes>(serviceChainProvider: URLServiceChainProviderMock())
        
        // when

        let result: NodeResult<Json> = await chainsBuilder
            .route(.post, .multipartPing)
            .build()
            .process(model)

        // then

        let value = try XCTUnwrap(result.value as? [String: Bool])

        XCTAssertEqual(value, ["success": true])
    }

    func testFileSendsCorrectly() async throws {
        // given
        
        let url = Bundle(for: type(of: self)).url(forResource: "Info", withExtension: "plist")!
        let model = MultipartModel(payloadModel: TestData(data: [:]) ,files: [
            "file": .url(url: url)
        ])
        let chainsBuilder = URLChainBuilder<Routes>(serviceChainProvider: URLServiceChainProviderMock())

        // when

        let result: NodeResult<Json> = await chainsBuilder
            .route(.post, .multipartPing)
            .build()
            .process(model)

        // then

        let value = try XCTUnwrap(result.value as? [String: Bool])

        XCTAssertEqual(value, ["success": true])
    }
}
