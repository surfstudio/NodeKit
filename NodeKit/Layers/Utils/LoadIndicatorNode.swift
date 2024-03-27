//
//  LoadIndicatorNode.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 14/04/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

#if canImport(UIKit)
import UIKit
#endif
import Dispatch

private enum LoadIndicatableNodeStatic {
    static var requestConter: Int = 0 {
        didSet {
            #if canImport(UIKit)
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = requestConter != 0
            }
            #endif
        }
    }
}

/// Показыает спиннер загрзки в статус-баре.
open class LoadIndicatableNode<Input, Output>: AsyncNode {

    /// Следующий узел в цепочке.
    open var next: any AsyncNode<Input, Output>

    /// Инциаллизирует узел.
    ///
    /// - Parameter next: Следующий узел в цепочке.
    public init(next: some AsyncNode<Input, Output> ) {
        self.next = next
    }

    /// Показывает индикатор и передает управление дальше.
    /// По окнчании работы цепочки скрывает индикатор.
    open func process(_ data: Input) -> Observer<Output> {
        DispatchQueue.global().async(flags: .barrier) {
            LoadIndicatableNodeStatic.requestConter += 1
        }

        let decrementRequestCounter: (() -> Void) = {
            DispatchQueue.global().async(flags: .barrier) {
                LoadIndicatableNodeStatic.requestConter -= 1
            }
        }

        return self.next.process(data)
            .map { (item: Output) -> Output in
                decrementRequestCounter()
                return item
            }.mapError { (error: Error) -> Error in
                decrementRequestCounter()
                return error
            }
    }

    /// Показывает индикатор и передает управление дальше.
    /// По окнчании работы цепочки скрывает индикатор.
    open func process(
        _ data: Input,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<Output> {
        DispatchQueue.global().async(flags: .barrier) {
            LoadIndicatableNodeStatic.requestConter += 1
        }

        let decrementRequestCounter: (() -> Void) = {
            DispatchQueue.global().async(flags: .barrier) {
                LoadIndicatableNodeStatic.requestConter -= 1
            }
        }

        let result = await next.process(data, logContext: logContext)
        decrementRequestCounter()
        return result
    }
}
