//
//  LoginResponseProvider.swift
//
//
//  Created by Andrei Frolov on 15.04.24.
//

import Foundation
import Models

enum LoginResponseProvider {
    
    // MARK: - Constants
    
    private enum Constants {
        static let accessToken = "accessToken"
        static let refreshToken = "refreshToken"
        static let statusCode = 200
    }
    
    // MARK: - Methods
    
    static func provide() throws -> (HTTPURLResponse, Data) {
        let model = AuthTokenResponseEntity(
            accessToken: Constants.accessToken,
            refreshToken: Constants.refreshToken
        )
        let data = try JSONSerialization.data(withJSONObject: try model.toDTO().toRaw())
        return (
            HTTPURLResponse(
                url: ServerConstants.hostURL,
                statusCode: Constants.statusCode,
                httpVersion: nil,
                headerFields: nil
            )!,
            data
        )
    }
}
