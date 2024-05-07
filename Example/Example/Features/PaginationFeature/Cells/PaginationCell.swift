//
//  PaginationCell.swift
//  Example
//
//  Created by Alexander Kravchenkov on 09.04.2018.
//  Copyright © 2018 Кравченков Александр. All rights reserved.
//

import Foundation
import NukeExtensions
import ReactiveDataDisplayManager
import UIKit
import Utils

final class PaginationCell: UITableViewCell, ConfigurableItem {
    
    // MARK: - Constants
    
    private enum Constants {
        static let cornerRadius: CGFloat = 16
        static let imageTransitionDuration: TimeInterval = 0.3
    }

    // MARK: - Subviews
    
    @IBOutlet private weak var icon: UIImageView!
    @IBOutlet private weak var shimmerView: BaseLoadingView!
    @IBOutlet private weak var titleLabel: UILabel!
    
    // MARK: - Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        icon.layer.cornerRadius = Constants.cornerRadius
        shimmerView.layer.cornerRadius = Constants.cornerRadius
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        icon.image = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureShimmerView()
    }
    
    // MARK: - Methods
    
    func configure(with model: PaginationCellViewModel) {
        startShimmer()
        titleLabel.text = model.name
        loadImage(with: URL(string: model.url)!, into: icon, completion: { [weak self] _ in
            self?.stopShimmer()
        })
    }
}

// MARK: - Private Methods

private extension PaginationCell {
    
    func configureShimmerView() {
        shimmerView.configure(blocks: makeShimmerBlocks(), config: makeShimmerConfig())
    }
    
    func makeShimmerBlocks() -> [LoadingViewBlock] {
        let model = BaseLoadingSubviewModel(height: icon.frame.height, cornerRadius: Constants.cornerRadius)
        return [
            BaseLoadingViewBlock<BaseLoadingSubview>(model: model)
        ]
    }
    
    func makeShimmerConfig() -> LoadingViewConfig {
        return LoadingViewConfig (placeholderColor: .gray.withAlphaComponent(0.2))
    }
    
    func startShimmer() {
        shimmerView.setNeedAnimating(true)
        shimmerView.isHidden = false
    }
    
    func stopShimmer() {
        shimmerView.setNeedAnimating(false)
        shimmerView.isHidden = true
    }
}
