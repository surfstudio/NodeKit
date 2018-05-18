//
//  ErrorAdapter.swift
//  GoLamaGo
//
//  Created by Alexander Kravchenkov on 05.10.17.
//  Copyright © 2017 Surf. All rights reserved.
//

import Foundation

/// Privide error mapping
public protocol ErrorMapperAdapter {

    /// Provide mapping json to custom error
    ///
    /// - Parameters:
    ///   - json: JSON object
    ///   - httpCode: code of http response
    /// - Returns: mapped error
    func map(json: [String: Any], httpCode: Int?) -> Error?

    /// Provide mapping json to custom errro
    ///
    /// - Parameters:
    ///   - json: JSON object
    ///   - httpCode: code of http response
    /// - Returns: mapped error
    func map(json: Any?, httpCode: Int?) -> Error?
}

extension ErrorMapperAdapter {
    public func map(json: Any?, httpCode: Int?) -> Error? {
        guard let dict = json as? [String: Any] else {
            return nil
        }
        return self.map(json: dict, httpCode: httpCode)
    }
}
