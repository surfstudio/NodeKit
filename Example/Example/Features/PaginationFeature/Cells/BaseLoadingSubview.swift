//
//  BaseLoadingSubview.swift
//  Example
//
//  Created by Andrei Frolov on 18.04.24.
//  Copyright © 2024 Кравченков Александр. All rights reserved.
//

import UIKit
import Utils

struct BaseLoadingSubviewModel {
    let height: CGFloat
    let cornerRadius: CGFloat
}

final class BaseLoadingSubview: UIView, LoadingSubview, LoadingSubviewConfigurable {
    typealias Model = BaseLoadingSubviewModel
    
    var height: CGFloat = 0
    
    func configure(color: UIColor) {
        backgroundColor = color
    }
    
    func configure(model: BaseLoadingSubviewModel) {
        height = model.height
        layer.cornerRadius = model.cornerRadius
    }
}
