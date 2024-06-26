//
//  GroupResponseProvider.swift
//
//
//  Created by Andrei Frolov on 15.04.24.
//

import Foundation
import Models

enum GroupResponseProvider {
    
    // MARK: - Constants
    
    private enum Constants {
        static let headerText = "Header"
        static let headerImage = "https://loremflickr.com/500/500?random1"
        static let bodyText = "Body"
        static let bodyImage = "https://loremflickr.com/500/500?random2"
        static let footerText = "Footer"
        static let footerImage = "https://loremflickr.com/500/500?random3"
        static let statusCode = 200
    }
    
    // MARK: - Methods
    
    static func provideHeader() throws -> (HTTPURLResponse, Data) {
        let model = GroupHeaderResponseEntity(text: Constants.headerText, image: Constants.headerImage)
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
    
    static func provideBody() throws -> (HTTPURLResponse, Data) {
        let model = GroupBodyResponseEntity(text: Constants.bodyText, image: Constants.bodyImage)
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
    
    static func provideFooter() throws -> (HTTPURLResponse, Data) {
        let model = GroupFooterResponseEntity(text: Constants.footerText, image: Constants.footerImage)
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
