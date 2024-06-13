//
//  GroupViewController.swift
//  Example
//
//  Created by Andrei Frolov on 15.04.24.
//  Copyright © 2024 Кравченков Александр. All rights reserved.
//

import NukeExtensions
import UIKit

struct GroupViewModel {
    let headerTitle: String
    let headerImage: String
    let bodyTitle: String
    let bodyImage: String
    let footerTitle: String
    let footerImage: String
}

@MainActor
protocol GroupViewInput: AnyObject, ErrorRepresentable {
    func update(with model: GroupViewModel)
    func showLoader()
    func hideLoader()
}

final class GroupViewController: UIViewController {
    
    // MARK: - Subviews
    
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var headerTitleLabel: UILabel!
    @IBOutlet private weak var headerImageView: UIImageView!
    @IBOutlet private weak var bodyTitleLabel: UILabel!
    @IBOutlet private weak var bodyImageView: UIImageView!
    @IBOutlet private weak var footerTitleLabel: UILabel!
    @IBOutlet private weak var footerImageView: UIImageView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    
    var output: GroupViewOutput?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        output?.viewDidLoad()
    }
}

// MARK: - GroupViewInput

extension GroupViewController: GroupViewInput {
    
    func update(with model: GroupViewModel) {
        headerTitleLabel.text = model.headerTitle
        bodyTitleLabel.text = model.bodyTitle
        footerTitleLabel.text = model.footerTitle
        loadImage(with: URL(string: model.headerImage)!, into: headerImageView)
        loadImage(with: URL(string: model.bodyImage)!, into: bodyImageView)
        loadImage(with: URL(string: model.footerImage)!, into: footerImageView)
    }
    
    func showLoader() {
        containerView.isHidden = true
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoader() {
        containerView.isHidden = false
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
}
