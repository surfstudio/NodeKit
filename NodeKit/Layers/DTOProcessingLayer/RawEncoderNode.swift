//
//  RawEncoderNode.swift
//  NodeKit
//
//  Created by Александр Кравченков on 18/05/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// Этот узел умеет конвертировать ВХОДНЫЕ данные в RAW, НО не пытается декодировать ответ.
open class RawEncoderNode<Input, Output>: Node<Input, Output> where Input: RawEncodable {

    /// Узел, который умеет работать с RAW
    open var next: Node<Input.Raw, Output>

    /// Инициаллизирует объект
    ///
    /// - Parameter rawEncodable: Узел, который умеет работать с RAW.
    public init(next: Node<Input.Raw, Output>) {
        self.next = next
    }

    /// Пытается конвертировать модель в RAW, а затем просто передает результат конвертации следующему узлу.
    /// Если при конвертирвоании произошла ошибка - прерывает выполнение цепочки.
    ///
    /// - Parameter data: Входящая модель.
    override open func process(_ data: Input) -> Observer<Output> {
        do {
            return next.process(try data.toRaw())
        } catch {
            return .emit(error: error)
        }
    }
}
