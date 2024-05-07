//
//  FeatureListViewController.swift
//  Example
//
//  Created by Andrei Frolov on 15.04.24.
//  Copyright © 2024 Кравченков Александр. All rights reserved.
//

import ReactiveDataDisplayManager
import UIKit

protocol FeatureListViewInput: AnyObject {
    func update(with generators: [TableCellGenerator])
}

final class FeatureListViewController: UIViewController {
    
    // MARK: - Constants
    
    private enum Constants {
        static let title = "Features"
        static let contentOffset: CGPoint = CGPoint(x: .zero, y: -60)
    }
    
    // MARK: - Subivews
    
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: - Properties
    
    var output: FeatureListViewOutput?
    
    // MARK: - Private Properties
    
    private lazy var tableManager = tableView
        .rddm
        .baseBuilder
        .build()
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        output?.viewDidLoad()
    }
}

// MARK: - FeatureListViewInput

extension FeatureListViewController: FeatureListViewInput {
    
    func update(with generators: [TableCellGenerator]) {
        tableManager.clearCellGenerators()
        tableManager.addCellGenerators(generators)
        tableManager.forceRefill()
    }
}

// MARK: - Private Methods

private extension FeatureListViewController {
    
    func configure() {
        configureTableView()
        configureTitle()
    }
    
    func configureTableView() {
        tableView.contentOffset = Constants.contentOffset
        tableView.showsVerticalScrollIndicator = false
    }
    
    func configureTitle() {
        title = Constants.title
    }
    
    func configureNavigationBar() {
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .black
    }
}
