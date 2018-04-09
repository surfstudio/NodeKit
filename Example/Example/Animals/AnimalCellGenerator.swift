//
//  AnimalCellGenerator.swift
//  Example
//
//  Created by Alexander Kravchenkov on 09.04.2018.
//  Copyright © 2018 Кравченков Александр. All rights reserved.
//

import Foundation
import ReactiveDataDisplayManager

class AnimalCellGenerator {
    private let url: String
    private let name: String

    public init(url: String, name: String) {
        self.url = url
        self.name = name
    }
}

extension AnimalCellGenerator: TableCellGenerator {
    var identifier: UITableViewCell.Type {
        return AnimalCell.self
    }
}

extension AnimalCellGenerator: ViewBuilder {
    func build(view: AnimalCell) {
        view.configure(name: self.name, url: self.url)
    }
}
