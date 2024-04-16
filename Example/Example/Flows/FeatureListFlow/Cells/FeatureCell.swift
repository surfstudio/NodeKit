//
//  FeatureCell.swift
//  Example
//
//  Created by Andrei Frolov on 15.04.24.
//  Copyright © 2024 Кравченков Александр. All rights reserved.
//

import ReactiveDataDisplayManager
import UIKit

final class FeatureCell: UITableViewCell {
    
    // MARK: - Constants
    
    private enum Constants {
        static var cornerRadius: CGFloat = 16
        static var shadowOpacity: Float = 0.3
        static var shadowOffset: CGSize = CGSize(width: 3, height: 3)
        static var shadowRadius: CGFloat = 3
        static var pressStateScale: CGFloat = 0.95
    }
    
    // MARK: - Subviews
    
    @IBOutlet private weak var contentContainerView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    
    // MARK: - Properties
    
    var didTap: (@MainActor () -> Void)?
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureGesture()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentContainerView.layer.shadowColor = UIColor.black.cgColor
        contentContainerView.layer.shadowOpacity = Constants.shadowOpacity
        contentContainerView.layer.shadowOffset = Constants.shadowOffset
        contentContainerView.layer.shadowRadius = Constants.shadowRadius
        contentContainerView.layer.cornerRadius = Constants.cornerRadius
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        updatePressState(isActive: true)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        updatePressState(isActive: false)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        updatePressState(isActive: false)
    }
    
    // MARK: - Methods
    
    func configure(with title: String) {
        titleLabel.text = title
    }
}

// MARK: - Private Methods

private extension FeatureCell {
    
    func configureGesture() {
        let recognizer = UITapGestureRecognizer()
        recognizer.addTarget(self, action: #selector(tapAction))
        contentContainerView.addGestureRecognizer(recognizer)
    }
    
    func updatePressState(isActive: Bool) {
        UIView.animate(withDuration: 0.1, animations: {
            guard isActive else {
                self.contentContainerView.transform = .identity
                return
            }
            let scale = Constants.pressStateScale
            self.contentContainerView.transform = .init(scaleX: scale, y: scale)
        })
    }
}

// MARK: - Actions

private extension FeatureCell {
    
    @objc
    func tapAction(_ sender: UITapGestureRecognizer) {
        didTap?()
    }
}
