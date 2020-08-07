//
//  StateStorable.swift
//  NodeKit
//

protocol StateStorable {
    func saveState()
    func clearStates()
    func restoreState()
}
