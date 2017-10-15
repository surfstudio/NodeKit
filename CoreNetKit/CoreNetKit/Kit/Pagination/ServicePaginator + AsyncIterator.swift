//
//  ServiceAsyncIterator.swift
//  GoLamaGo
//
//  Created by Alexander Kravchenkov on 13.09.17.
//  Copyright © 2017 Surf. All rights reserved.
//

import Foundation

/// This is contract for object that must Incapsulate pagination processing
public protocol ServicePaginator {

    // MARK: - Types definition

    associatedtype Model

    // MARK: - Methods

    /// Move iterator to next item.
    func moveNext()

    /// Reset iterator to current index
    ///
    /// - Parameter index: - new start index.
    func reset(to index: Int?)
}

public protocol ServiceAsyncIterator: ServicePaginator {

    /// True if items pages was end else false
    var canMoveNext: Bool { get }
}
