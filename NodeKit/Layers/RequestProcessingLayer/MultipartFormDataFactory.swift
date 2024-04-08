//
//  MultipartFormDataFactory.swift
//  NodeKit
//
//  Created by Andrei Frolov on 05.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

import ThirdParty

/// Протокол фабрики для создания объекта, позволяющего собирать multipart/form-data.
public protocol MultipartFormDataFactory {
    
    /// Метод создания объекта.
    ///
    /// - Returns: Объекта для сборки multipart/form-data.
    func produce() -> MultipartFormDataProtocol
}

/// Фабрика для создания MultipartFormData - реализации Alamofire.
public struct AlamofireMultipartFormDataFactory: MultipartFormDataFactory {
    
    // MARK: - Initialization
    
    public init() { }
    
    // MARK: - MultipartFormDataFactory
    
    /// Метод создания объекта.
    ///
    /// - Returns: Реализация протокола ``MultipartFormDataProtocol`` от Alamofire.
    public func produce() -> MultipartFormDataProtocol {
        return MultipartFormData()
    }
}
