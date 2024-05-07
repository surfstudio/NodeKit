import Foundation

/// Этот узел выполняет выведение лога в консоль.
/// Сразу же передает управление следующему узлу и подписывается на выполнение операций.
open class LoggerNode<Input, Output>: AsyncNode {
    /// Следующий узел для обработки.
    open var next: any AsyncNode<Input, Output>
    /// Содержит список ключей, по которым будет отфлитрован лог.
    open var filters: [String]

    /// Инициаллизирует объект.
    ///
    /// - Parameters:
    ///   - next: Следующий узел для обработки.
    ///   - filters: Содержит список ключей, по которым будет отфлитрован лог.
    public init(next: any AsyncNode<Input, Output>, filters: [String] = []) {
        self.next = next
        self.filters = filters
    }

    /// Сразу же передает управление следующему узлу и подписывается на выполнение операций.
    ///
    /// - Parameter data: Данные для обработки. Этот узел их не использует.
    open func process(
        _ data: Input,
        logContext: LoggingContextProtocol
    ) async -> NodeResult<Output> {
        let result = await next.process(data, logContext: logContext)

        await logContext.log?.flatMap()
            .filter { !filters.contains($0.id) }
            .sorted(by: { $0.order < $1.order })
            .forEach {
                print($0.description)
            }

        return result
    }
}
