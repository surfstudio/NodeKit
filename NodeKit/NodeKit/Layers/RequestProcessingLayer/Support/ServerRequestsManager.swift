//
//  ServerRequestsManager.swift
//  CoreNetKit
//
//  Created by Александр Кравченков on 23/03/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

public class ServerRequestsManager {

    /// The single instance of the `ServerRequestsManager` object.
    public static let shared = ServerRequestsManager()

    /// Session manager..
    public let manager: URLSession

    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForResource = 60 * 3
        configuration.timeoutIntervalForRequest = 60 * 3
        configuration.requestCachePolicy = .reloadIgnoringCacheData
        configuration.urlCache = nil
        self.manager = URLSession(configuration: configuration)
    }

}
