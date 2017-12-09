//
//  ViewController.swift
//  Example
//
//  Created by Александр Кравченков on 09.12.2017.
//  Copyright © 2017 Кравченков Александр. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet
    fileprivate weak var loginCartView: UIView!

    @IBOutlet
    weak var loginCartLoginActionButton: UIButton!
    
    @IBOutlet
    fileprivate weak var loginCartYConstraint: NSLayoutConstraint!

    @IBOutlet
    fileprivate weak var loginCartImage: UIImageView!

    @IBOutlet
    fileprivate weak var loginCartEmailTextField: UITextField!

    @IBOutlet
    fileprivate weak var loginCartPasswordTextField: UITextField!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configure()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeSubscriptions()
    }

}

// MARK: - IBActions

extension LoginViewController {
    
    @IBAction
    func actionLoginButtonTouchUpInside(_ sender: Any) {

    }
}

// MARK: - Notifications

private extension LoginViewController {

    func subscribeOnNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyBoardDidHide(_:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }

    func removeSubscriptions() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc
    func keyboardDidShow(_ notification: NSNotification) {
        guard let userInfo = notification.userInfo,
            let keyboardRect = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect,
            self.loginCartView.frame.maxY > keyboardRect.minY else {
            return
        }

        self.loginCartYConstraint.constant -= self.loginCartView.frame.maxY - keyboardRect.minY

        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
            self.loginCartView.layoutIfNeeded()
        }
    }

    @objc
    func keyBoardDidHide(_ notification: NSNotification) {
        UIView.animate(withDuration: 0.2) {
            self.loginCartYConstraint.constant = 0
            self.loginCartView.layoutIfNeeded()
        }
    }
}

// MARK: - Configuration

private extension LoginViewController {

    func configure() {
        self.configureUI()
        self.subscribeOnNotifications()
    }

    func configureUI() {
        self.configureImage()
        self.configureTextFields()
        self.configureLoginButton()
    }

    func configureLoginButton() {
        self.loginCartLoginActionButton.clipsToBounds = true
        self.loginCartLoginActionButton.layer.cornerRadius = 5
    }

    func configureImage() {
        self.loginCartImage.layer.cornerRadius = 20
        self.loginCartImage.clipsToBounds = true
    }

    func configureTextFields() {
        self.loginCartEmailTextField.keyboardType = .emailAddress
        self.loginCartEmailTextField.placeholder = "Your email"

        self.loginCartPasswordTextField.placeholder = "Your password"
    }
}

