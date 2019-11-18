import Foundation
import Foundation
import Combine

@available(iOS 13.0, *)
public class PublisherContextWrapper<O>: Publisher, Cancellable {

    public typealias Output = O
    public typealias Failure = Error

    public var completed: ((O) -> Void)?
    public var error: ((Error) -> Void)?

    public var publisher: PublisherContext<O>

    init(publisher: PublisherContext<O>){
        self.publisher = publisher
    }

    public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, O == S.Input {
        self.publisher.receive(subscriber: subscriber)
    }

    public func cancel() {
        fatalError()
    }

    open func onError(_ closure: @escaping (Error) -> Void) -> Self {
        self.error = closure
        return self
    }
}
