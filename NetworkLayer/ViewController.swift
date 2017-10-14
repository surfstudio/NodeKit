//
//  ViewController.swift
//  NetworkLayer
//
//  Created by Александр Кравченков on 27.09.17.
//  Copyright © 2017 Кравченков Александр. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let context = ExampleService.send()
        context.onCompleted {
            print("context on completed called")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

