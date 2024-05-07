//
//  ViewController.swift
//  Example
//
//  Created by Александр Кравченков on 09.12.2017.
//  Copyright © 2017 Кравченков Александр. All rights reserved.
//

import UIKit
import SwiftMessages

class LoginViewController: UIViewController {

    // MARK: - Subviews

    @IBOutlet private weak var loginCartView: UIView!
    @IBOutlet private weak var loginCartLoginActionButton: UIButton!
    @IBOutlet private weak var loginCartYConstraint: NSLayoutConstraint!
    @IBOutlet private weak var loginCartImage: UIImageView!
    @IBOutlet private weak var loginCartEmailTextField: UITextField!
    @IBOutlet private weak var loginCartPasswordTextField: UITextField!

    // MARK: - Properties

    var output: LoginViewOutput?

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
        let credentials = Credentials(
            email: loginCartEmailTextField.text,
            password: loginCartPasswordTextField.text
        )
        output?.credentialsDidReceive(credentials: credentials)
    }
}

// MARK: - Notifications

private extension LoginViewController {

    func subscribeOnNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyBoardDidHide(_:)), name: UIResponder.keyboardDidHideNotification, object: nil)
    }

    func removeSubscriptions() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc
    func keyboardDidShow(_ notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardRect = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            self.loginCartView.frame.maxY > keyboardRect.minY else {
            return
        }

        loginCartYConstraint.constant -= self.loginCartView.frame.maxY - keyboardRect.minY

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
        configureUI()
        subscribeOnNotifications()
    }

    func configureUI() {
        configureImage()
        configureTextFields()
        configureLoginButton()
    }

    func configureLoginButton() {
        loginCartLoginActionButton.clipsToBounds = true
        loginCartLoginActionButton.layer.cornerRadius = 5
    }

    func configureImage() {
        loginCartImage.layer.cornerRadius = 20
        loginCartImage.clipsToBounds = true
    }

    func configureTextFields() {
        loginCartEmailTextField.keyboardType = .emailAddress
        loginCartEmailTextField.placeholder = "Your email"

        loginCartPasswordTextField.placeholder = "Your password"
    }
}
