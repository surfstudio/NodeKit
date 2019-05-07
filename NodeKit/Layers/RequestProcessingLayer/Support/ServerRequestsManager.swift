//
//  ServerRequestsManager.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 23/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation
import Alamofire

/// Менеджер запросов к серверу.
/// Работает c `SessionManager` и является синглтоном.
public class ServerRequestsManager {

    /// Единственный инстанс объекта `ServerRequestsManager`
    public static let shared = ServerRequestsManager()

    /// Менеджер сессий.
    public let manager: Session

    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForResource = 60 * 3
        configuration.timeoutIntervalForRequest = 60 * 3
        configuration.requestCachePolicy = .reloadIgnoringCacheData
        configuration.urlCache = nil
        self.manager = Alamofire.Session(configuration: configuration)
    }
}
