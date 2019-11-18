import Foundation
import Alamofire
import Combine

/// Этот узел отправляет запрос на сервер и ожидает ответ.
/// - Important: этот узел имеет состояние (statefull)
open class RequestSenderNode<Type>: Node<RawUrlRequest, Type>, Aborter {

    /// Тип для узла, который будет обрабатывать ответ от сервера.
    public typealias RawResponseProcessor = Node<DataResponse<Data>, Type>

    /// Узел для обработки ответа.
    public var rawResponseProcessor: RawResponseProcessor

    private weak var request: DataRequest?
    private weak var context: Observer<DataResponse<Data>>?

    /// Инициаллизирует узел.
    ///
    /// - Parameter rawResponseProcessor: Узел для обработки ответа.
    public init(rawResponseProcessor: RawResponseProcessor) {
        self.rawResponseProcessor = rawResponseProcessor
    }

    /// Выполняет запрос,ожидает ответ и передает его следующему узлу.
    ///
    /// - Parameter data: Данные для исполнения запроса.
    open override func process(_ data: RawUrlRequest) -> Observer<Type> {

        let context = Context<DataResponse<Data>>()

        self.context = context
        var log = Log(self.logViewObjectName, id: self.objectName, order: LogOrder.requestSenderNode)
        self.request = data.dataRequest.responseData(queue: DispatchQueue.global(qos: .userInitiated)) { (response) in
            log += "Get response!)"
            context.log(log).emit(data: response)
        }
        log += "Request sended!"
        return context.map { self.rawResponseProcessor.process($0) }
    }

    @available(iOS 13.0, *)
    open override func make(_ data: RawUrlRequest) -> PublisherContext<Type> {

        let future = Future<DataResponse<Data>, Error> { promise in
            self.request = data.dataRequest.responseData(queue: DispatchQueue.global(qos: .userInitiated)) { (response) in
                promise(.success(response))
            }
        }
        return future
            .flatMap { self.rawResponseProcessor.make($0) }
            .asContext()
    }

    /// Отменяет запрос.
    open func cancel() {
        self.context?.log?.add(message: "Request was cancelled!")
        self.request?.cancel()
        self.context?.cancel()
    }
}
