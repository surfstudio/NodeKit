//
//  ErrorResponseProvider.swift
//
//
//  Created by Andrei Frolov on 15.04.24.
//

import Foundation

enum ErrorResponseProvider {
    
    static func provide400Error() -> (HTTPURLResponse, Data) {
        return (
            HTTPURLResponse(
                url: ServerConstants.hostURL,
                statusCode: 400,
                httpVersion: nil,
                headerFields: nil
            )!,
            Data()
        )
    }
}
