//
//  UrlProvider.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 05/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

/// ИНтерфей для провайдера URL маршрутов
public protocol UrlRouteProvider {

    /// Возвращает URL
    ///
    /// - Returns: URL-маршрут этого объекта
    /// - Throws: Может вызвать исключение в случае, если состояние объекта не позволяет вернуть маршрут.
    func url() throws -> URL
}
