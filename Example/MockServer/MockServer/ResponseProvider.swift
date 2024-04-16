//
//  ResponseProvider.swift
//
//
//  Created by Andrei Frolov on 15.04.24.
//

import Foundation

protocol ResponseProvider {
    static func make400Error() -> (HTTPURLResponse, Data)
}

extension ResponseProvider {
    
    static func make400Error() -> (HTTPURLResponse, Data) {
        return (
            HTTPURLResponse(
                url: URL(string: "http://www.mockurl.com")!,
                statusCode: 400,
                httpVersion: nil,
                headerFields: nil
            )!,
            Data()
        )
    }
}
