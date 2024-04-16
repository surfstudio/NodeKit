//
//  FeatureCellViewModel.swift
//  Example
//
//  Created by Andrei Frolov on 15.04.24.
//  Copyright © 2024 Кравченков Александр. All rights reserved.
//

final class FeatureCellViewModel {
    
    // MARK: - Properties
    
    var didTap: (() -> Void)?
    
    let title: String
    
    // MARK: - Initialization
    
    init(title: String) {
        self.title = title
    }
}
