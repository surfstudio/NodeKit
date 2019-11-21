import Foundation

/// Этот узел выполняет выведение лога в консоль.
/// Сразу же передает управление следующему узлу и подписывается на выполнение операций.
open class LoggerNode<Input, Output>: Node<Input, Output> {
    /// Следующий узел для обработки.
    open var next: Node<Input, Output>
    /// Содержит список ключей, по которым будет отфлитрован лог.
    open var filters: [String]

    /// Инициаллизирует объект.
    ///
    /// - Parameters:
    ///   - next: Следующий узел для обработки.
    ///   - filters: Содержит список ключей, по которым будет отфлитрован лог.
    public init(next: Node<Input, Output>, filters: [String] = []) {
        self.next = next
        self.filters = filters
    }

    /// Сразу же передает управление следующему узлу и подписывается на выполнение операций.
    ///
    /// - Parameter data: Данные для обработки. Этот узел их не импользует. 
    open override func process(_ data: Input) -> Observer<Output> {
        let result = Context<Output>()

        let context = self.next.process(data)

        let filter = self.filters

        let log = { (log: Logable?) -> Void in
            guard let log = log else { return }

            log.flatMap()
                .filter { !filter.contains($0.id) }
                .sorted(by: { $0.order < $1.order })
                .forEach { print($0.description) }
        }

        context.onCompleted { data in
            log(context.log)
            result.log(context.log).emit(data: data)
        }.onError { error in
            log(context.log)
            result.log(context.log).emit(error: error)
        }.onCanceled {
            log(context.log)
            result.log(context.log).cancel()
        }

        return result
    }
}
