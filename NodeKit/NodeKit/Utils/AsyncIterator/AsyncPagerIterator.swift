//
//  AsyncPagerIterator.swift
//  NodeKit
//

/// Provides the ability to paginate using offsets.
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
    
    /// Requests data from the provider and updates the state upon successful result.
    @discardableResult
    public func next() async -> Result<Value, Error> {
        return await dataProvider.provide(for: currentState.index, with: currentState.pageSize)
            .flatMap { data in
                currentState.index += data.len
                currentState.hasNext = data.len != 0 && data.len >= currentState.pageSize
                return .success(data.value)
            }
    }
    
    /// Returns whether there is more data for the current state.
    public func hasNext() -> Bool {
        return currentState.hasNext
    }
    
    /// Resets the current state.
    public func renew() {
        currentState.index = 0
        currentState.hasNext = true
    }
    
    // MARK: - StateStorable
    
    /// Adds the current state to the list of saved states.
    public func saveState() {
        statesStore.append(currentState)
    }
    
    /// Deletes all saved states.
    public func clearStates() {
        statesStore.removeAll()
    }
    
    /// Changes the current state to the last saved one, removing it from the list of saved states.
    public func restoreState() {
        currentState = statesStore.last != nil ? statesStore.removeLast() : currentState
    }
}
