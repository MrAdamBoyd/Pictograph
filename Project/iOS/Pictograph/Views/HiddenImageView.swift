//
//  HiddenImageView.swift
//  Pictograph
//
//  Created by Adam Boyd on 2017/6/16.
//  Copyright © 2017 Adam Boyd. All rights reserved.
//

import Foundation
import UIKit

protocol HiddenImageViewDelegate: class {
    func showShareSheetFromHiddenImageView()
    func closeModalViewFromModal(_ completion: (() -> Void)?)
}

class HiddenImageView: PictographModalView {
    
    /// Displays a new hidden image view in a new uiwindow
    ///
    /// - Parameter delegate: delegate for any actions
    /// - Returns: the window (which needs to be retained), and the view
    static func createInWindow(from delegate: HiddenImageViewDelegate?, showing image: UIImage) -> (window: UIWindow, view: HiddenImageView) {
        
        let view = HiddenImageView(frame: .zero)
        view.delegate = delegate
        view.imageView.image = image
        return PictographModalView.createViewInWindow(viewToShow: view)
    }
    
    // MARK: - Subviews
    
    fileprivate lazy var titleLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "Hidden Image"
        $0.font = UIFont.systemFont(ofSize: 24)
        return $0
    }(UILabel(frame: .zero))
    
    fileprivate lazy var shareImageButton: PictographModalButton = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("Share Image", for: .normal)
        return $0
    }(PictographModalButton(frame: .zero))
    
    fileprivate lazy var closeViewButton: PictographModalButton = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("Close", for: .normal)
        return $0
    }(PictographModalButton(frame: .zero))
    
    fileprivate lazy var imageView: UIImageView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFit
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.gray.cgColor
        return $0
    }(UIImageView(frame: .zero))
    
    // MARK: - Properties
    
    weak var delegate: HiddenImageViewDelegate?
    
    // MARK: - Functions
    
    /// Adds all subviews to self and sets up the constraints. Does not start animation
    override func setUpSubviewConstraints(for window: UIWindow) {
        super.setUpSubviewConstraints(for: window)
        
        //Title label
        self.addSubview(self.titleLabel)
        self.titleLabel.centerXAnchor.constraint(equalTo: self.popupView.centerXAnchor).isActive = true
        self.titleLabel.topAnchor.constraint(equalTo: self.popupView.topAnchor, constant: 10).isActive = true
        
        //Imageview
        self.addSubview(self.imageView)
        self.imageView.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 10).isActive = true
        self.imageView.leftAnchor.constraint(equalTo: self.popupView.leftAnchor, constant: 10).isActive = true
        self.imageView.rightAnchor.constraint(equalTo: self.popupView.rightAnchor, constant: -10).isActive = true
        if window.traitCollection.verticalSizeClass == .compact {
            //Limit the height of the image view if compact
            self.imageView.heightAnchor.constraint(equalTo: self.imageView.widthAnchor, multiplier: 1/3).isActive = true
        } else {
            self.imageView.heightAnchor.constraint(equalTo: self.imageView.widthAnchor, multiplier: 2/3).isActive = true
        }
        
        //Close button
        self.addSubview(self.closeViewButton)
        self.closeViewButton.topAnchor.constraint(equalTo: self.imageView.bottomAnchor, constant: 20).isActive = true
        self.closeViewButton.leadingAnchor.constraint(equalTo: self.imageView.leadingAnchor).isActive = true
        self.closeViewButton.trailingAnchor.constraint(equalTo: self.popupView.centerXAnchor, constant: -10).isActive = true
        self.closeViewButton.bottomAnchor.constraint(equalTo: self.popupView.bottomAnchor, constant: -20).isActive = true
        self.closeViewButton.addTarget(self, action: #selector(self.closeButtonTapped), for: .touchUpInside)
        
        //Share Image button
        self.addSubview(self.shareImageButton)
        self.shareImageButton.topAnchor.constraint(equalTo: self.imageView.bottomAnchor, constant: 20).isActive = true
        self.shareImageButton.leadingAnchor.constraint(equalTo: self.popupView.centerXAnchor, constant: 10).isActive = true
        self.shareImageButton.trailingAnchor.constraint(equalTo: self.imageView.trailingAnchor).isActive = true
        self.shareImageButton.addTarget(self, action: #selector(self.shareSheetTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc func closeButtonTapped() {
        self.delegate?.closeModalViewFromModal(nil)
    }
    
    @objc func shareSheetTapped() {
        self.delegate?.showShareSheetFromHiddenImageView()
    }
}
