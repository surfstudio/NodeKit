//
//  PaginationLoadingView.swift
//  Example
//
//  Created by Andrei Frolov on 11.04.24.
//  Copyright © 2024 Кравченков Александр. All rights reserved.
//

import ReactiveDataDisplayManager
import SnapKit
import UIKit

final class PaginationLoadingView: UIView, ProgressDisplayableItem {
    
    // MARK: - Constants
    
    private enum Constants {
        static let activityIndicatorSize: CGFloat = 30
    }
    
    // MARK: - Subviews
    
    private let activityIndicator = UIActivityIndicatorView()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureAcitvityIndicator()
        self.frame.size.height = Constants.activityIndicatorSize
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureAcitvityIndicator()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureAcitvityIndicator()
    }
    
    // MARK: - ProgressDisplayableItem
    
    func showProgress(_ isLoading: Bool) {
        if isLoading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
    func showError(_ error: (Error)?) { }
    func setOnRetry(action: @escaping () -> Void) { }
}

// MARK: - Private Methods

private extension PaginationLoadingView {
    
    func configureAcitvityIndicator() {
        addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.width.height.equalTo(Constants.activityIndicatorSize)
        }
    }
}
