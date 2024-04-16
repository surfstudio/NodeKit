//
//  FeatureCellGenerator.swift
//  Example
//
//  Created by Andrei Frolov on 15.04.24.
//  Copyright © 2024 Кравченков Александр. All rights reserved.
//

import ReactiveDataDisplayManager
import UIKit

class FeatureCellGenerator {
    
    // MARK: - Private Properties
    
    private let title: String
    
    // MARK: - Properties
    
    var didTap: (@MainActor () -> Void)?
    
    // MARK: - Initialization

    public init(_ title: String) {
        self.title = title
    }
}

// MARK: - TableCellGenerator

extension FeatureCellGenerator: TableCellGenerator {
    
    var identifier: String {
        return "FeatureCell"
    }
}

// MARK: - ViewBuilder

extension FeatureCellGenerator: ViewBuilder {
    func build(view: FeatureCell) {
        view.configure(with: title)
        view.didTap = didTap
    }
}
