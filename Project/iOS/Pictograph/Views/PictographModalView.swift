//
//  PictographModalView.swift
//  Pictograph
//
//  Created by Adam on 9/16/17.
//  Copyright © 2017 Adam Boyd. All rights reserved.
//

import Foundation
import UIKit

class PictographModalView: UIView {
    /// Displays the provided modal view
    ///
    /// - parameter viewToShow: Which modal view to show
    /// - Returns: the window (which needs to be retained), and the view
    static func createViewInWindow<T: PictographModalView>(viewToShow: T) -> (window: UIWindow, view: T) {
        let window = UIWindow.newWindow(statusBarStyle: .default)
        
        viewToShow.translatesAutoresizingMaskIntoConstraints = false
        window.addSubview(viewToShow)
        window.alpha = 0
        window.isHidden = false
        
        viewToShow.widthAnchor.constraint(equalTo: window.widthAnchor).isActive = true
        viewToShow.heightAnchor.constraint(equalTo: window.heightAnchor).isActive = true
        viewToShow.centerXAnchor.constraint(equalTo: window.centerXAnchor).isActive = true
        viewToShow.centerYAnchor.constraint(equalTo: window.centerYAnchor).isActive = true
        
        //Animating the window to be visible and the popup in
        UIView.animate(withDuration: modalPresentingAnimationDuration, animations: {
            window.alpha = 1
        }, completion: { _ in
            viewToShow.animateCenterPopup(visible: true, completion: nil)
        })
        
        return (window: window, view: viewToShow)
    }
    
    // MARK: - Subviews
    lazy var backgroundView: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.65)
        return $0
    }(UIVisualEffectView(frame: .zero))
    
    lazy var popupView: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .white
        return $0
    }(UIView(frame: .zero))
    
    // MARK: - Properties
    
    var popupCenterConstraint: NSLayoutConstraint!
    
    var popupNonVisibleCenterPosition: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    // MARK: - Initializing
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpSubviewConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setUpSubviewConstraints()
    }
    
    /// Adds all subviews to self and sets up the constraints. Does not start animation
    func setUpSubviewConstraints() {
        
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
        
    }
    
    /// Animates the center popup
    ///
    /// - Parameter visible: Makes the popup visible if true, false otherwise
    func animateCenterPopup(visible: Bool, completion: (() -> Void)?) {
        DispatchQueue.main.async { [unowned self] in
            let newConstant = visible ? 0 : self.popupNonVisibleCenterPosition
            self.popupCenterConstraint.constant = newConstant
            
            UIView.animate(withDuration: modalPresentingAnimationDuration, animations: {
                self.layoutIfNeeded()
            }, completion: { _ in
                completion?()
            })
        }
    }
    
}
