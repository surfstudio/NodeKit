import Foundation
import XCTest

@testable import NodeKit

public class MultipartRequestTests: XCTestCase {

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

    public func testMultipartPing() {

        // Arrange

        let data = TestData(data: [
            "file1": Data(),
            "file2": Data(),
            "file3": Data(),
        ])

        // Act

        var isSuccess = false

        let exp = self.expectation(description: "\(#function)")

        let model = MultipartModel(payloadModel: data)

        UrlChainsBuilder()
            .route(.post, Routes.multipartPing)
            .build()
            .process(model)
            .onCompleted { (json: Json) in
                isSuccess = json["success"] as! Bool
                exp.fulfill()
            }

        waitForExpectations(timeout: 3, handler: nil)

        // Assert
        XCTAssertTrue(isSuccess)
    }

    public func testValuesSendsCorrectly() {

        // Arrange

        let data = TestData(data: [
            "word1": "Test".data(using: .utf8)!,
            "word2": "Success".data(using: .utf8)!,
        ])

        // Act

        var isSuccess = false

        let exp = self.expectation(description: "\(#function)")

        let model = MultipartModel(payloadModel: data)

        UrlChainsBuilder()
            .route(.post, Routes.multipartCorrect)
            .build()
            .process(model)
            .onCompleted { (json: Json) in
                isSuccess = json["success"] as! Bool
                exp.fulfill()
        }

        waitForExpectations(timeout: 3, handler: nil)

        // Assert
        XCTAssertTrue(isSuccess)
    }

    public func testFileSendsCorrectly() {

        // Arrange
        let url = Bundle(for: type(of: self)).url(forResource: "LICENSE", withExtension: "txt")!
        let model = MultipartModel(payloadModel: TestData(data: [:]) ,files: [
            "file": .url(url: url)
        ])

        // Act

        var isSuccess = false

        let exp = self.expectation(description: "\(#function)")

        UrlChainsBuilder()
            .route(.post, Routes.multipartFile)
            .build()
            .process(model)
            .onCompleted { (json: Json) in
                isSuccess = json["success"] as! Bool
                exp.fulfill()
        }

        waitForExpectations(timeout: 30, handler: nil)

        // Assert
        XCTAssertTrue(isSuccess)
    }
}
