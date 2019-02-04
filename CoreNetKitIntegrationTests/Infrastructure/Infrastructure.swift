//
//  Infrastructure.swift
//  CoreNetKitIntegrationTests
//
//  Created by Александр Кравченков on 28/01/2019.
//  Copyright © 2019 Кравченков Александр. All rights reserved.
//

import Foundation

public final class Infrastructure {
    public static let baseURL = URL(string: "http://127.0.0.1:8811")!

    public static let getUsersURL = URL(string: "users", relativeTo: baseURL)!

    public static let getEmptyUserArray = URL(string: "userAmptyArr", relativeTo: baseURL)!

    public static let authWithFormUrl = URL(string: "authWithFormUrl", relativeTo: baseURL)!
}
