//
//  CancellableTask.swift
//
//
//  Created by Andrei Frolov on 15.04.24.
//

import Foundation

public protocol CancellableTask {
    func cancel()
}

extension Task: CancellableTask { }
extension URLSessionDataTask: CancellableTask { }
