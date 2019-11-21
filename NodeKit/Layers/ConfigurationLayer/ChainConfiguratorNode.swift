
import Foundation

/// Конфигурирующий узел.
/// Всегда должен быть корневым узлом в графе обработчиков.
/// Этот узел позволяет установить очередь на которой будет происходит дальнейшая обработк запроса
/// И очередь на которой обработка будет закончена.
open class ChainConfiguratorNode<I, O>: Node<I, O> {

    /// Следующей узел для обработки.
    public var next: Node<I, O>
    /// Очерель на которой необходимо выполнить все дальнейшие преобразования.
    public var beginQueue: DispatchQueue
    /// Очередь на которой необходимо выполнить возврат результата работы цепочки.
    public var endQueue: DispatchQueue

    /// Инициаллизирует узел.
    ///
    /// - Parameters:
    ///   - next: Следующей узел для обработки.
    ///   - beginQueue: Очерель на которой необходимо выполнить все дальнейшие преобразования.
    ///   - endQueue: Очередь на которой необходимо выполнить возврат результата работы цепочки.
    public init(next: Node<I, O>, beginQueue: DispatchQueue, endQueue: DispatchQueue) {
        self.next = next
        self.beginQueue = beginQueue
        self.endQueue = endQueue
    }

    /// Вспомогательный инциализатор.
    /// Для очередие используются значения по-умолчанию:
    /// - `beginQueue = .global(qos: .userInitiated)`
    /// - `endQueue = .main`
    ///
    /// - Parameter next: Следующей узел для обработки.
    public convenience init(next: Node<I, O>) {
        self.init(next: next, beginQueue: .global(qos: .userInitiated), endQueue: .main)
    }

    /// Созздает асинхронный контект с очередью `beginQueue`,
    /// затем выполняет всю цепочку операций и диспатчит ответ на `endQueue`
    ///
    /// - Parameter data: Данные для обработки
    open override func process(_ data: I) -> Observer<O> {
        return Context<Void>.emit(data: ())
            .dispatchOn(self.beginQueue)
            .map { return self.next.process(data) }
            .dispatchOn(self.endQueue)
    }
}
