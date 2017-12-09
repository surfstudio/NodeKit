//
//  CacheableContext.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 09.12.2017.
//  Copyright © 2017 Кравченков Александр. All rights reserved.
//

import Foundation

/// Devide success completion on cache completion and server completion
public protocol CacheableContext {

    associatedtype ResultType

    /// Called if coupled object completed operation succesfully
    ///
    /// - Parameter closure: callback
    func onCacheCompleted(_ closure: @escaping (ResultType) -> Void)
}
