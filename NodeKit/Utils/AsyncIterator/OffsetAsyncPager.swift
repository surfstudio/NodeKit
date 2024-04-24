//
//  OffsetAsyncPager.swift
//  NodeKit
//

/// Предоставляет возможность делать пагинацию на оффсетах
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
