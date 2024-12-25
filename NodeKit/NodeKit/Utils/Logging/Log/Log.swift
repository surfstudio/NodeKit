//
//  Log.swift
//
//
//  Created by frolov on 24.12.2024.
//

public protocol Log {

    /// The order of the log in the chain. Necessary for sorting.
    var order: Double { get }

    /// Log identifier.
    var id: String { get }

    /// The content of this log.
    var message: String { get }

    /// Type of the log
    var logType: LogType { get }

}
