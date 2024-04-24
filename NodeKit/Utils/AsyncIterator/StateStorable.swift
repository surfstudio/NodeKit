//
//  StateStorable.swift
//  NodeKit
//

protocol StateStorableLegacy {
    func saveState()
    func clearStates()
    func restoreState()
}

public protocol StateStorable: Actor {
    func saveState()
    func clearStates()
    func restoreState()
}
