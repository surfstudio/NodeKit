//
//  PaginationResponseProvider.swift
//
//
//  Created by Andrei Frolov on 15.04.24.
//

import Foundation
import Models

enum PaginationResponseProvider {
    
    // MARK: - Constants
    
    private enum Constants {
        static let indexKey = "index"
        static let pageSizeKey = "pageSize"
        static let title = "Pagination Item"
        static let image = "https://picsum.photos/"
        static let statusCode = 200
        static let itemsCount = 100
    }
    
    // MARK: - Private Parameters
    
    private static let items = (0...Constants.itemsCount).map {
        let width = 300 + $0
        let height = 200 + $0
        return PaginationResponseEntity(
            name: Constants.title + " \($0)",
            image: Constants.image + "\(width)/\(height)"
        )
    }
    
    // MARK: - Methods
    
    static func provide(for request: URLRequest) throws -> (HTTPURLResponse, Data) {
        guard
            let index = getIndexParameter(from: request),
            let pageSize = getPageSizeParameter(from: request)
        else {
            return ErrorResponseProvider.provide400Error()
        }
        
        let responseArray = makeResponseArray(index: index, pageSize: pageSize)
        let data = try JSONSerialization.data(withJSONObject: try responseArray.toDTO().toRaw())
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

// MARK: - Private Methods

private extension PaginationResponseProvider {
    
    private static func getIndexParameter(from request: URLRequest) -> Int? {
        guard
            let url = request.url,
            let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true),
            let index = urlComponents.queryItems?.first(where: { $0.name == Constants.indexKey })?.value
        else {
            return nil
        }
        
        return Int(index)
    }
    
    private static func getPageSizeParameter(from request: URLRequest) -> Int? {
        guard
            let url = request.url,
            let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true),
            let pageSize = urlComponents.queryItems?.first(where: { $0.name == Constants.pageSizeKey })?.value
        else {
            return nil
        }
        
        return Int(pageSize)
    }
    
    private static func makeResponseArray(index: Int, pageSize: Int) -> [PaginationResponseEntity] {
        guard index < Constants.itemsCount else {
            return []
        }
        
        return Array(items.suffix(from: index).prefix(pageSize))
    }
}
