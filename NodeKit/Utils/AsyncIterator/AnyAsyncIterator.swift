//
//  AnyAsyncIterator.swift
//  NodeKit
//

/// Является type erasure для `AsyncIterator`.
/// Должен использоваться вместо конкретного типа итератора в переменной (см. пример)
///
///
/// - Example:
/// ```Swfit
///
/// let iterator: AnyAsyncIterator<String>
///
/// func makeIterator() {
///     let specific = YourCustomIterator<String>(...)
///     self.iterator = AnyAsyncIterator(nested: specific)
/// }
///
/// func iterate() {
///     self.iterator.next()...
/// }
///
/// ```
struct AnyAsyncIterator<Value>: AsyncIterator {

    // MARK: - Private Properties

    private let nested: BaseAsyncPager<Value>

    // MARK: - Initialization

    init<Nested>(nested: Nested) where Nested: AsyncIterator, Nested.Value == Value {
        self.nested = AsyncPagerBox(nested: nested)
    }

    // MARK: - AsyncIterator

    func next() -> Observer<Value> {
        return self.nested.next()
    }

    func renew() {
        self.nested.renew()
    }

    func onEnd(_ closure: @escaping () -> Void) {
        self.nested.onEnd(closure)
    }

}

// MARK: - Private Helpers

private class AsyncPagerBox<Value, Nested>: BaseAsyncPager<Value> where Nested: AsyncIterator, Nested.Value == Value {

    let nested: Nested

    init(nested: Nested) {
        self.nested = nested
    }

    override func next() -> Observer<Value> {
        return self.nested.next()
    }

    override func renew() {
        self.nested.renew()
    }

    override func onEnd(_ closure: @escaping () -> Void) {
        self.nested.onEnd(closure)
    }

}

private class BaseAsyncPager<Value>: AsyncIterator {

    func next() -> Observer<Value> {
        preconditionFailure("\(self.self) \(#function) not implemented")
    }

    func renew() {
        preconditionFailure("\(self.self) \(#function) not implemented")
    }

    public func onEnd(_ closure: @escaping () -> Void) {
        preconditionFailure("\(self.self) \(#function) not implemented")
    }

}
