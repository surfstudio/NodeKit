//
//  Credentials.swift
//  Example
//
//  Created by Andrei Frolov on 15.04.24.
//  Copyright © 2024 Кравченков Александр. All rights reserved.
//

struct Credentials {
    let email: String
    let password: String
}

extension Credentials {
    
    init?(email: String?, password: String?) {
        guard let email, let password else {
            return nil
        }
        self.email = email
        self.password = password
    }
}
