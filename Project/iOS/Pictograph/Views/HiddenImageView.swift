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
    func closeHiddenImageView(_ completion: (() -> Void)?)
}

class HiddenImageView: UIView {
    
    /// Displays a new hidden image view in a new uiwindow
    ///
    /// - Parameter delegate: delegate for any actions
    /// - Returns: the window (which needs to be retained), and the view
    static func createInWindow(from delegate: HiddenImageViewDelegate?, with image: UIImage) -> (window: UIWindow, view: HiddenImageView) {
        let window = UIWindow.newWindow(statusBarStyle: .default)
        let hiddenImageView = HiddenImageView(frame: .zero)
        hiddenImageView.delegate = delegate
        
        hiddenImageView.translatesAutoresizingMaskIntoConstraints = false
        window.addSubview(hiddenImageView)
        window.alpha = 0
        window.isHidden = false
        
        hiddenImageView.widthAnchor.constraint(equalTo: window.widthAnchor).isActive = true
        hiddenImageView.heightAnchor.constraint(equalTo: window.heightAnchor).isActive = true
        hiddenImageView.centerXAnchor.constraint(equalTo: window.centerXAnchor).isActive = true
        hiddenImageView.centerYAnchor.constraint(equalTo: window.centerYAnchor).isActive = true
        
        hiddenImageView.imageView.image = image
        
        //Animating the window to be visible and the popup in
        UIView.animate(withDuration: 0.5, animations: {
            window.alpha = 1
        }, completion: { _ in
            hiddenImageView.animateCenterPopup(visible: true, completion: nil)
        })
        
        return (window: window, view: hiddenImageView)
    }
    
    // MARK: - Subviews
    fileprivate lazy var backgroundView: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.65)
        return $0
    }(UIVisualEffectView(frame: .zero))
    
    fileprivate lazy var popupView: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .white
        return $0
    }(UIView(frame: .zero))
    
    fileprivate lazy var titleLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont(name: "Avenir-Medium", size: 22)
        $0.text = "Hidden Image"
        return $0
    }(UILabel(frame: .zero))
    
    fileprivate lazy var shareImageButton: UIButton = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("Share Image", for: .normal)
        $0.setTitleColor(.blue, for: .normal)
        return $0
    }(UIButton(frame: .zero))
    
    fileprivate lazy var closeViewButton: UIButton = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("Close", for: .normal)
        $0.setTitleColor(.blue, for: .normal)
        return $0
    }(UIButton(frame: .zero))
    
    fileprivate lazy var imageView: UIImageView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIImageView(frame: .zero))
    
    // MARK: - Properties
    
    weak var delegate: HiddenImageViewDelegate?
    var popupCenterConstraint: NSLayoutConstraint!
    
    var popupNonVisibleCenterPosition: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    // MARK: - Functions
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpSubviewConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setUpSubviewConstraints()
    }
    
    /// Adds all subviews to self and sets up the constraints. Does not start animation
    fileprivate func setUpSubviewConstraints() {
        
        //Background view
        self.addSubview(self.backgroundView)
        self.backgroundView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        self.backgroundView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.backgroundView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        self.backgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        //Popup view
        self.addSubview(self.popupView)
        self.popupView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
        self.popupView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20).isActive = true
        self.popupCenterConstraint = self.popupView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: self.popupNonVisibleCenterPosition)
        self.popupCenterConstraint.isActive = true
        
        self.popupView.layer.masksToBounds = false
        self.popupView.layer.borderColor = UIColor.gray.cgColor
        self.popupView.layer.borderWidth = 1
        self.popupView.layer.shadowOpacity = 0.25
        self.popupView.layer.shadowRadius = 1
        self.popupView.layer.shadowOffset = CGSize.zero
        
        //Title label
        self.addSubview(self.titleLabel)
        self.titleLabel.centerXAnchor.constraint(equalTo: self.popupView.centerXAnchor).isActive = true
        self.titleLabel.topAnchor.constraint(equalTo: self.popupView.topAnchor, constant: 10).isActive = true
        
        //Imageview
        self.addSubview(self.imageView)
        self.imageView.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 10).isActive = true
        self.imageView.leftAnchor.constraint(equalTo: self.popupView.leftAnchor, constant: 10).isActive = true
        self.imageView.rightAnchor.constraint(equalTo: self.popupView.rightAnchor, constant: -10).isActive = true
        self.imageView.heightAnchor.constraint(equalTo: self.imageView.widthAnchor, multiplier: 2/3).isActive = true
        
        //Share Image button
        self.addSubview(self.shareImageButton)
        self.shareImageButton.topAnchor.constraint(equalTo: self.imageView.bottomAnchor, constant: -10).isActive = true
        self.shareImageButton.leadingAnchor.constraint(equalTo: self.imageView.leadingAnchor).isActive = true
        self.shareImageButton.trailingAnchor.constraint(equalTo: self.popupView.centerXAnchor).isActive = true
        self.shareImageButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 10).isActive = true
        
        //Close button
        self.addSubview(self.closeViewButton)
        self.closeViewButton.centerYAnchor.constraint(equalTo: self.shareImageButton.centerYAnchor).isActive = true
        self.closeViewButton.leadingAnchor.constraint(equalTo: self.popupView.centerXAnchor).isActive = true
        self.closeViewButton.trailingAnchor.constraint(equalTo: self.imageView.trailingAnchor).isActive = true
    }
    
    /// Animates the center popup
    ///
    /// - Parameter visible: Makes the popup visible if true, false otherwise
    func animateCenterPopup(visible: Bool, completion: (() -> Void)?) {
        DispatchQueue.main.async { [unowned self] in
            let newConstant = visible ? 0 : self.popupNonVisibleCenterPosition
            self.popupCenterConstraint.constant = newConstant
            
            UIView.animate(withDuration: 0.5, animations: {
                self.layoutIfNeeded()
            }, completion: { _ in
                completion?()
            })
        }
    }
    
    // MARK: - Actions
    @objc func closeButtonTapped() {
        self.delegate?.closeHiddenImageView(nil)
    }
    
    @objc func shareSheetTapped() {
        self.delegate?.showShareSheetFromHiddenImageView()
    }
}
