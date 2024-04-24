//
//  OffsetAsyncPager.swift
//  NodeKit
//

/// Предоставляет возможность делать пагинацию на оффсетах
///
/// Метод `onEnd` сработает только после того как вернется значение
///
/// То есть если будет `pageSize` равным 30, но `DataProvider` вернет 25 элементов (меньше чем надо)
/// то тогда после возвращение элементов будет вызван `onEnd`
///
/// - Warning: onCompleted вызывается всегда кроме error cases даже если придет пустой ответ
///
/// - Example:
///
/// ```Swift
///
/// var iterator: AnyAsyncIterator<[City]>
/// var service: CityService
///
/// func makeIterator() {
///
///     self.iterator.dataProvider = { [weak self] (index, pageSize) in
///         guard let self = self else { return .emit(data: []) }
///
///         return self.service.getCity(from: index, by: pageSize).map { dataWithMeta
///             return (dataWithMeta.cities, dataWithMeta.cities.count)
///         }
///     }
///
///     self.iterator.onEnd { [weak self] in
///         self?.view?.endPaging()
///     }
///
/// }
///
/// ```

class OffsetAsyncPagerLegacy<Value>: AsyncIteratorLegacy, StateStorableLegacy {

    /// Возвращаемый тип и количество элементов для увеличения смещения
    typealias PagingData = (data: Value, len: Int)
    /// Специальный объект, который выполняет пагинацию, например, через запросы на сервер на основе index и pageSize
    typealias DataProvider = (_ index: Int, _ pageSize: Int) -> Observer<PagingData>

    private struct PagerState {
        var index: Int
        var pageSize: Int
    }

    private var onEndClosure: (() -> Void)?
    var dataProvider: DataProvider?

    private var currentState: PagerState
    private var statesStore = [PagerState]()

    init(dataPrivider: DataProvider? = nil, pageSize: Int) {
        self.dataProvider = dataPrivider
        self.currentState = .init(index: 0, pageSize: pageSize)
        self.onEndClosure = nil
    }

    func next() -> Observer<Value> {

        guard let dp = self.dataProvider else {
            return .emit(error: PagingErrorLegacy.dataProviderNotSet)
        }

        return dp(currentState.index, currentState.pageSize).map { [weak self] (data, len) -> Value in

            guard let self = self else {
                return data
            }

            self.currentState.index += len

            if len == 0 || len < self.currentState.pageSize {
                self.onEndClosure?()
            }

            return data
        }
    }

    func renew() {
        currentState.index = 0
    }

    func onEnd(_ closure: @escaping () -> Void) {
        onEndClosure = closure
    }

    func saveState() {
        statesStore.append(currentState)
    }

    func clearStates() {
        statesStore.removeAll()
    }

    func restoreState() {
        currentState = statesStore.last != nil ? statesStore.removeLast() : currentState
    }

}

public actor OffsetAsyncPager<Value>: AsyncIterator, StateStorable {
    
    /// Возвращаемый тип и количество элементов для увеличения смещения
    typealias PagingData = (data: Value, len: Int)
    /// Специальный объект, который выполняет пагинацию, например, через запросы на сервер на основе index и pageSize
    typealias DataProvider = (_ index: Int, _ pageSize: Int) -> NodeResult<PagingData>

    private struct PagerState {
        var index: Int
        var pageSize: Int
    }

    private let dataProvider: DataProvider
    private var currentState: PagerState
    private var statesStore = [PagerState]()
    
    init(dataProvider: @escaping DataProvider, pageSize: Int) {
        self.dataProvider = dataProvider
        self.currentState = PagerState(index: 0, pageSize: pageSize)
    }
    
    public func next() -> Result<(data: Value, end: Bool), Error> {
        return dataProvider(currentState.index, currentState.pageSize)
            .flatMap { (data, len) in
                currentState.index += len
                return .success((data, len == 0 || len < currentState.pageSize))
            }
    }
    
    public func renew() {
        currentState.index = 0
    }
    
    public func saveState() {
        statesStore.append(currentState)
    }
    
    public func clearStates() {
        statesStore.removeAll()
    }
    
    public func restoreState() {
        currentState = statesStore.last != nil ? statesStore.removeLast() : currentState
    }
}
