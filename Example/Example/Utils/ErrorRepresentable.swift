//
//  ErrorRepresentable.swift
//  Example
//
//  Created by Andrei Frolov on 15.04.24.
//  Copyright © 2024 Кравченков Александр. All rights reserved.
//

import SwiftMessages

protocol ErrorRepresentable {
 
    @MainActor
    func show(error: Error)
}

extension ErrorRepresentable {
    
    @MainActor
    func show(error: Error) {
        let messageView = MessageView.viewFromNib(layout: .cardView)
        messageView.configureTheme(.error)
        messageView.configureDropShadow()
        messageView.configureContent(title: "Error", body: error.localizedDescription, iconText: "😳")
        messageView.button?.isHidden = true
        SwiftMessages.show(view: messageView)
    }
}
