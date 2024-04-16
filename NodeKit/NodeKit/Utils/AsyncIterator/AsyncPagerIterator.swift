//
//  AsyncPagerIterator.swift
//  NodeKit
//

/// Предоставляет возможность делать пагинацию на оффсетах
public actor AsyncPagerIterator<Value>: AsyncIterator, StateStorable {
    
    // MARK: - Nested Types

    private struct PagerState {
        var index: Int
        var pageSize: Int
        var hasNext: Bool
    }
    
    // MARK: - Private Properties

    private let dataProvider: any AsyncPagerDataProvider<Value>
    private var currentState: PagerState
    private var statesStore = [PagerState]()
    
    // MARK: - Initialization
    
    public init(dataProvider: any AsyncPagerDataProvider<Value>, pageSize: Int) {
        self.dataProvider = dataProvider
        self.currentState = PagerState(index: 0, pageSize: pageSize, hasNext: true)
    }
    
    // MARK: - AsyncIterator
    
    /// Запрашивает данные у провайдера и при успешном результате обновляет состояние.
    public func next() async -> Result<Value, Error> {
        return await dataProvider.provide(for: currentState.index, with: currentState.pageSize)
            .flatMap { data in
                currentState.index += data.len
                currentState.hasNext = data.len != 0 && data.len >= currentState.pageSize
                return .success(data.value)
            }
            .mapError {
                currentState.hasNext = false
                return $0
            }
    }
    
    /// Возвращает есть ли еще данные для текущего состояния.
    public func hasNext() -> Bool {
        return currentState.hasNext
    }
    
    /// Сбрасывает текущее состояние.
    public func renew() {
        currentState.index = 0
        currentState.hasNext = true
    }
    
    // MARK: - StateStorable
    
    /// Добавляет текущее состояние в список сохраненных.
    public func saveState() {
        statesStore.append(currentState)
    }
    
    /// Удаляет все сохарненные состояния.
    public func clearStates() {
        statesStore.removeAll()
    }
    
    /// Меняет текущее состояние на последнее сохраненное, удаляя его из списка сохранненых.
    public func restoreState() {
        currentState = statesStore.last != nil ? statesStore.removeLast() : currentState
    }
}
