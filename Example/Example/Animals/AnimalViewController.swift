//
//  AnimalViewController.swift
//  Example
//
//  Created by Alexander Kravchenkov on 09.04.2018.
//  Copyright © 2018 Кравченков Александр. All rights reserved.
//

import Foundation
import UIKit
import ReactiveDataDisplayManager
import SwiftMessages

class AnimalViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var adapter = BaseTableDataDisplayManager(estimatedHeight: 40)
    var presenter = AnimalPresernter()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.view = self
        self.adapter.set(collection: self.tableView)
        self.adapter.scrollViewWillEndDraggingEvent += { [weak self] velocity in
            if velocity.y < 0 {
                self?.adapter.clearCellGenerators()
                self?.presenter.loadAnimals()
            } else {
                self?.presenter.next()
            }
        }
        self.presenter.loadAnimals()
    }

    func add(models: [AnimalEntity]) {
        models.forEach { (entity) in
            let generator = AnimalCellGenerator(url: entity.image, name: entity.name)
            self.adapter.addCellGenerator(generator)
        }
        self.adapter.forceRefill()
    }

    func showError(_ error: Error) {
        let view = MessageView.viewFromNib(layout: .cardView)
        view.configureTheme(.error)
        view.configureDropShadow()
        view.configureContent(title: "Error", body: error.localizedDescription, iconText: "😳")
        SwiftMessages.show(view: view)
    }
}
