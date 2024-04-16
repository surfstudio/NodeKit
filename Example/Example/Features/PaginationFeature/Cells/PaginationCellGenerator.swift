//
//  PaginationCellGenerator.swift
//  Example
//
//  Created by Alexander Kravchenkov on 09.04.2018.
//  Copyright © 2018 Кравченков Александр. All rights reserved.
//

import ReactiveDataDisplayManager
import UIKit

class PaginationCellGenerator {
    
    // MARK: - Private Properties
    
    private let name: String
    private let url: String

    // MARK: - Initialization
    
    init(name: String, url: String) {
        self.name = name
        self.url = url
    }
}

// MARK: - TableCellGenerator

extension PaginationCellGenerator: TableCellGenerator {
    
    var identifier: String {
        return "PaginationCell"
    }
}

// MARK: - ViewBuilder

extension PaginationCellGenerator: ViewBuilder {
    func build(view: PaginationCell) {
        view.configure(name: name, url: url)
    }
}
