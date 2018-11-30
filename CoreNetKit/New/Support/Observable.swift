//
//  Observable.swift
//  CoreNetKitWithExample
//
//  Created by Александр Кравченков on 27/11/2018.
//  Copyright © 2018 Александр Кравченков. All rights reserved.
//

import Foundation

protocol DefaultInitable {
    init()
}

protocol Observable {
    associatedtype Model

    @discardableResult
    func onCompleted(_ closure: @escaping (Model) -> Void) -> Self
    @discardableResult
    func onError(_ closure: @escaping (Error) -> Void) -> Self
    @discardableResult
    func `defer`(_ closure: @escaping () -> Void) -> Self
}
