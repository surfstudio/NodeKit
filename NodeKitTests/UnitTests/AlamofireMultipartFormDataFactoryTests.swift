//
//  AlamofireMultipartFormDataFactoryTests.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 05.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

@testable import NodeKit
import XCTest

final class AlamofireMultipartFormDataFactoryTests: XCTestCase {
    
    // MARK: - Sut
    
    private var sut: AlamofireMultipartFormDataFactory!
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        sut = AlamofireMultipartFormDataFactory()
    }
    
    override func tearDown() {
        sut = nil
    }
    
    // MARK: - Tests
    
    func testProduce_thenMultipartFormDataCreated() throws {
        // when
        
        let multipartFormData = sut.produce()
        
        // then
        
        let castedMultipartFormData = try XCTUnwrap(multipartFormData as? MultipartFormData)
        
        XCTAssertEqual(castedMultipartFormData.fileManager, FileManager.default)
    }
    
}
