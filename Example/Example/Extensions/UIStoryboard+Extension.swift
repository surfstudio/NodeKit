//
//  UIStoryboard+Extension.swift
//  Example
//
//  Created by Andrei Frolov on 15.04.24.
//  Copyright © 2024 Кравченков Александр. All rights reserved.
//

import UIKit

extension UIStoryboard {
    static func instantiate<ViewController: UIViewController>(
        ofType: ViewController.Type,
        bundle: Bundle = .main
    ) -> ViewController? {
        let storyboard = UIStoryboard(name: String(describing: ViewController.self), bundle: bundle)
        return storyboard.instantiateInitialViewController() as? ViewController
    }
}
