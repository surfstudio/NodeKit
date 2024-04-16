//
//  PaginationCell.swift
//  Example
//
//  Created by Alexander Kravchenkov on 09.04.2018.
//  Copyright © 2018 Кравченков Александр. All rights reserved.
//

import AlamofireImage
import Foundation
import UIKit

final class PaginationCell: UITableViewCell {
    
    // MARK: - Constants
    
    private enum Constants {
        static let cornerRadius: CGFloat = 16
        static let imageTransitionDuration: TimeInterval = 0.3
    }

    // MARK: - Subviews
    
    @IBOutlet private weak var icon: UIImageView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var titleLabel: UILabel!
    
    // MARK: - Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        icon.layer.cornerRadius = Constants.cornerRadius
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        icon.image = nil
        activityIndicator.startAnimating()
        activityIndicator?.isHidden = false
    }
    
    // MARK: - Methods
    
    func configure(name: String, url: String) {
        titleLabel.text = name
        icon.af.setImage(
            withURL: URL(string: url)!,
            imageTransition: .crossDissolve(Constants.imageTransitionDuration)
        ) { [weak self] _ in
            self?.activityIndicator?.stopAnimating()
            self?.activityIndicator?.isHidden = true
        }
    }
}
