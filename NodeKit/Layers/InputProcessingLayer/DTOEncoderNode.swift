import Foundation
import Combine

/// Этот узел умеет конвертировать ВХОДНЫЕ данные в DTO, НО не пытается декодировать ответ.
open class DTOEncoderNode<Input, Output>: Node<Input, Output> where Input: DTOEncodable {

    /// Узел, который умеет работать с DTO
    open var rawEncodable: Node<Input.DTO, Output>

    /// Инициаллизирует объект
    ///
    /// - Parameter rawEncodable: Узел, который умеет работать с DTO.
    public init(rawEncodable: Node<Input.DTO, Output>) {
        self.rawEncodable = rawEncodable
    }

    /// Пытается конвертировать модель в DTO, а затем просто передает результат конвертации следующему узлу.
    /// Если при конвертирвоании произошла ошибка - прерывает выполнение цепочки.
    ///
    /// - Parameter data: Входящая модель.
    override open func process(_ data: Input) -> Observer<Output> {
        do {
            return rawEncodable.process(try data.toDTO())
        } catch {
            return .emit(error: error)
        }
    }

    @available(iOS 13.0, *)
    open override func make(_ data: Input) -> PublisherContext<Output> {
        Just(data)
            .tryMap { try $0.toDTO() }
            .flatMap(self.rawEncodable.make)
            .asContext()
    }
}
