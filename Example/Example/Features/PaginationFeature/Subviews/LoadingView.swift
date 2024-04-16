//
//  LoadingView.swift
//  Example
//
//  Created by Andrei Frolov on 11.04.24.
//  Copyright © 2024 Кравченков Александр. All rights reserved.
//

import ReactiveDataDisplayManager
import UIKit

final class LoadingView: UIView, ProgressDisplayableItem {
    
    func showProgress(_ isLoading: Bool) { }
    
    func showError(_ error: (any Error)?) { }
    
    func setOnRetry(action: @escaping () -> Void) { }
}
