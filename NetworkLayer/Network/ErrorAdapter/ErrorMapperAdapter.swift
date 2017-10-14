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
    func map(json: [String: Any]) -> LocalizedError?

    /// Provide mapping json to custom errro
    func map(json: Any?) -> LocalizedError?
}

extension ErrorMapperAdapter {
    public func map(json: Any?) -> LocalizedError? {
        guard let dict = json as? [String: Any] else {
            return nil
        }
        return self.map(json: dict)
    }
}
