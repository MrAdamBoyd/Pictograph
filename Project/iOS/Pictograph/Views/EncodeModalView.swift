//
//  EncodeModalView.swift
//  Pictograph
//
//  Created by Adam Boyd on 2017/10/8.
//  Copyright © 2017 Adam Boyd. All rights reserved.
//

import Foundation
import UIKit

protocol EncodeModalViewDelegate: class {
    func encode(message: String?, hiddenImage: UIImage?)
    func closeModalViewFromModal(_ completion: (() -> Void)?)
}

class EncodeModalView: PictographModalView {
    
    /// Displays a new hidden image view in a new uiwindow
    ///
    /// - Parameter delegate: delegate for any actions
    /// - Returns: the window (which needs to be retained), and the view
    static func createInWindow(from delegate: EncodeModalViewDelegate?) -> (window: UIWindow, view: EncodeModalView) {
        
        let view = EncodeModalView(frame: .zero)
        view.delegate = delegate
        return PictographModalView.createViewInWindow(viewToShow: view)
    }
    
    // MARK: - Subviews
    
    fileprivate lazy var titleLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "Encode"
        $0.font = UIFont.systemFont(ofSize: 24)
        return $0
    }(UILabel(frame: .zero))
    
    private lazy var messageTextField: PictographInsetTextField = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.placeholder = "Enter text here"
        $0.layer.borderColor = UIColor.gray.cgColor
        $0.layer.borderWidth = 1
        return $0
    }(PictographInsetTextField(frame: .zero))
    
    fileprivate lazy var encodeButton: PictographModalButton = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("Start", for: .normal)
        return $0
    }(PictographModalButton(frame: .zero))
    
    fileprivate lazy var closeViewButton: PictographModalButton = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("Close", for: .normal)
        return $0
    }(PictographModalButton(frame: .zero))
    
    fileprivate lazy var imageInstructionLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "Tap to Select Image"
        $0.font = UIFont.systemFont(ofSize: 16)
        return $0
    }(UILabel(frame: .zero))
    
    fileprivate lazy var imageView: UIImageView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFit
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.gray.cgColor
        return $0
    }(UIImageView(frame: .zero))
    
    // MARK: - Properties
    
    weak var delegate: EncodeModalViewDelegate?
    
    // MARK: - Functions
    
    /// Adds all subviews to self and sets up the constraints. Does not start animation
    override func setUpSubviewConstraints(for window: UIWindow) {
        super.setUpSubviewConstraints(for: window)
        
        //Title label
        self.addSubview(self.titleLabel)
        self.titleLabel.centerXAnchor.constraint(equalTo: self.popupView.centerXAnchor).isActive = true
        self.titleLabel.topAnchor.constraint(equalTo: self.popupView.topAnchor, constant: 10).isActive = true
        
        //Message text field
        self.addSubview(self.messageTextField)
        self.messageTextField.leftAnchor.constraint(equalTo: self.popupView.leftAnchor, constant: 10).isActive = true
        self.messageTextField.rightAnchor.constraint(equalTo: self.popupView.rightAnchor, constant: -10).isActive = true
        self.messageTextField.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 10).isActive = true
        
        //Imageview
        self.addSubview(self.imageView)
        self.imageView.topAnchor.constraint(equalTo: self.messageTextField.bottomAnchor, constant: 10).isActive = true
        self.imageView.leftAnchor.constraint(equalTo: self.popupView.leftAnchor, constant: 10).isActive = true
        self.imageView.rightAnchor.constraint(equalTo: self.popupView.rightAnchor, constant: -10).isActive = true
        if window.traitCollection.verticalSizeClass == .compact {
            //Limit the height of the image view if compact
            self.imageView.heightAnchor.constraint(equalTo: self.imageView.widthAnchor, multiplier: 1/3).isActive = true
        } else {
            self.imageView.heightAnchor.constraint(equalTo: self.imageView.widthAnchor, multiplier: 2/3).isActive = true
        }
        
        self.addSubview(self.imageInstructionLabel)
        self.imageInstructionLabel.centerXAnchor.constraint(equalTo: self.imageView.centerXAnchor).isActive = true
        self.imageInstructionLabel.centerYAnchor.constraint(equalTo: self.imageView.centerYAnchor).isActive = true
        
        //Close button
        self.addSubview(self.closeViewButton)
        self.closeViewButton.topAnchor.constraint(equalTo: self.imageView.bottomAnchor, constant: 20).isActive = true
        self.closeViewButton.leadingAnchor.constraint(equalTo: self.imageView.leadingAnchor).isActive = true
        self.closeViewButton.trailingAnchor.constraint(equalTo: self.popupView.centerXAnchor, constant: -10).isActive = true
        self.closeViewButton.bottomAnchor.constraint(equalTo: self.popupView.bottomAnchor, constant: -20).isActive = true
        self.closeViewButton.addTarget(self, action: #selector(self.closeButtonTapped), for: .touchUpInside)
        
        //Share Image button
        self.addSubview(self.encodeButton)
        self.encodeButton.topAnchor.constraint(equalTo: self.imageView.bottomAnchor, constant: 20).isActive = true
        self.encodeButton.leadingAnchor.constraint(equalTo: self.popupView.centerXAnchor, constant: 10).isActive = true
        self.encodeButton.trailingAnchor.constraint(equalTo: self.imageView.trailingAnchor).isActive = true
        self.encodeButton.addTarget(self, action: #selector(self.startEncodingTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc func closeButtonTapped() {
        self.delegate?.closeModalViewFromModal(nil)
    }
    
    @objc func startEncodingTapped() {
        //TODO: Set message
        self.delegate?.encode(message: nil, hiddenImage: self.imageView.image)
    }
}
