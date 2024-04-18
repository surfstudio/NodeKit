//
//  FeatureCellViewModel.swift
//  Example
//
//  Created by Andrei Frolov on 15.04.24.
//  Copyright © 2024 Кравченков Александр. All rights reserved.
//

import UIKit

final class FeatureCellViewModel {
    
    // MARK: - Properties
    
    let title: String
    var didTap: (@MainActor () -> Void)?
    
    // MARK: - Initialization

    init(_ title: String) {
        self.title = title
    }
}
