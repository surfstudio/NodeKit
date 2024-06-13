//
//  PaginationViewController.swift
//  Example
//
//  Created by Andrei Frolov on 15.04.24.
//  Copyright © 2024 Кравченков Александр. All rights reserved.
//

import ReactiveDataDisplayManager
import UIKit

@MainActor 
protocol PaginationViewInput: AnyObject {
    func update(with generators: [TableCellGenerator])
    func add(generators: [TableCellGenerator])
    func disablePagination()
    func enablePagination()
    func showPaginationLoading()
    func hidePaginationLoading()
}

final class PaginationViewController: UIViewController {
    
    // MARK: - Subviews
    
    @IBOutlet private weak var tableView: UITableView!
    
    private let loadingView = PaginationLoadingView()
    private let refreshControl = UIRefreshControl()
    
    // MARK: - Private Properties
    
    private lazy var paginationPlugin: TablePaginatablePlugin = .paginatable(progressView: loadingView, output: self)
    private lazy var tableManager = tableView
        .rddm
        .baseBuilder
        .add(plugin: paginationPlugin)
        .build()
    
    // MARK: - Properties
    
    var output: PaginationViewOutput?
    
    // MARK: - Lifcycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        output?.viewDidLoad()
    }
}

// MARK: - Private Methods

private extension PaginationViewController {
    
    func configure() {
        configureTableView()
        configureRefreshControl()
    }
    
    func configureTableView() {
        tableView.showsVerticalScrollIndicator = false
        tableView.refreshControl = refreshControl
    }
    
    func configureRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refreshDidRequest), for: .valueChanged)
    }
    
    @objc
    func refreshDidRequest() {
        output?.refreshDidRequest()
    }
}

// MARK: - PaginationViewInput

extension PaginationViewController: PaginationViewInput {
    
    func update(with generators: [TableCellGenerator]) {
        refreshControl.endRefreshing()
        tableManager.clearCellGenerators()
        tableManager.addCellGenerators(generators)
        tableManager.forceRefill()
    }
    
    func add(generators: [TableCellGenerator]) {
        tableManager.addCellGenerators(generators)
        tableManager.forceRefill()
    }
    
    func disablePagination() {
        paginationPlugin.updatePagination(canIterate: false)
    }
    
    func enablePagination() {
        paginationPlugin.updatePagination(canIterate: true)
    }
    
    func showPaginationLoading() {
        paginationPlugin.updateProgress(isLoading: true)
    }
    
    func hidePaginationLoading() {
        paginationPlugin.updateProgress(isLoading: false)
    }
}

// MARK: - PaginatableOutput

extension PaginationViewController: PaginatableOutput {
    
    func onPaginationInitialized(with input: ReactiveDataDisplayManager.PaginatableInput) {
        input.updatePagination(canIterate: true)
    }
    
    func loadNextPage(with input: ReactiveDataDisplayManager.PaginatableInput) {
        output?.nextPageRequested()
    }
}
