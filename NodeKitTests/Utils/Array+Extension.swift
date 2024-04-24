//
//  Array+Extension.swift
//  NodeKitTests
//
//  Created by Andrei Frolov on 09.04.24.
//  Copyright © 2024 Surf. All rights reserved.
//

extension Array {
    func safe(index: Int) -> Element? {
        guard count > index else {
            return nil
        }
        return self[index]
    }
}
