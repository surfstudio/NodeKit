//
//  StateStorable.swift
//  NodeKit
//

public protocol StateStorable: Actor {
    func saveState()
    func clearStates()
    func restoreState()
}
