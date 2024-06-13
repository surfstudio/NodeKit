//
//  MultipartFormDataFactory.swift
//  NodeKit
//
//  Created by Andrei Frolov on 05.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import NodeKitThirdParty

/// Protocol for the factory to create an object capable of assembling multipart/form-data.
public protocol MultipartFormDataFactory {
    
    /// Method for creating the object.
    ///
    /// - Returns: Object for assembling multipart/form-data.
    func produce() -> MultipartFormDataProtocol
}

/// Factory for creating MultipartFormData - Alamofire implementation.
public struct AlamofireMultipartFormDataFactory: MultipartFormDataFactory {
    
    // MARK: - Initialization
    
    public init() { }
    
    // MARK: - MultipartFormDataFactory
    
    /// Method for creating the object.
    ///
    /// - Returns: Implementation of the `MultipartFormDataProtocol` protocol from Alamofire.
    public func produce() -> MultipartFormDataProtocol {
        return MultipartFormData()
    }
}
