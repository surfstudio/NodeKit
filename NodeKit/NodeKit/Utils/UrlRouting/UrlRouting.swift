//
//  URLRouting.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 03/04/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// Содержит ошибки для маршрутизатора URL запросов.
///
/// - cantBuildURL: Возникает в случае, если не удалось создать URL.
public enum URLRouteError: Error {
    case cantBuildURL
}

public extension Optional where Wrapped == URL {

    /// Операция конкатенации строки и URL.
    ///
    /// - Parameters:
    ///   - lhs: Базовый URL, относительно которого нужно построить итоговый.
    ///   - rhs: Относительный путь, который нужно добавить к базовому URL
    /// - Returns: Итоговый URL маршрут.
    /// - Throws: `URLRouteError.cantBuildURL`
    static func + (lhs: URL?, rhs: String) throws -> URL {
        guard let url = lhs?.appendingPathComponent(rhs) else {
            throw URLRouteError.cantBuildURL
        }
        return url
    }
}

/// Расширение для удобства оборачивания `URLRouteProvider`
/// - Warning:
/// Это используется исключительно для работы между узлами.
extension URL: URLRouteProvider {
    /// Просто возвращает себя
    public func url() throws -> URL {
        return self
    }
}
