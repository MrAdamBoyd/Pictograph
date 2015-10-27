//
//  PictographBarView.swift
//  Pictograph
//
//  Created by Adam Boyd on 2015-10-25.
//  Copyright © 2015 Adam Boyd. All rights reserved.
//

import Foundation
import UIKit

private let titleFontSize:CGFloat = 24
private let titleYOffset: CGFloat = 0
private let titleLeftRightOffset: CGFloat = 65

@objc
class PictographTopBarView: UIView {
    var titleLabel = UILabel()
    var accessoryButton = UIButton()
    var bottomBorder = UIView()
    var accessoryButtonAction: (() -> Void)?
    
    //MARK: - UIView
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //Adding the app title to the top of the screen
        titleLabel.font = UIFont.boldSystemFontOfSize(titleFontSize)
        titleLabel.textColor = UIColor.whiteColor()
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .Center
        
        //Centered on y, left & right by 65px
        addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: titleYOffset))
        addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: titleLeftRightOffset))
        addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: -titleLeftRightOffset))
        
        
        //Settings button
        accessoryButton.addTarget(self, action: Selector("buttonAction"), forControlEvents: .TouchUpInside)
        accessoryButton.setTitleColor(UIColor.whiteColor().colorWithAlphaComponent(0.5), forState: .Highlighted)
        accessoryButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(accessoryButton)
        
        //Bottom = titleLabel.bottom + 3, 16px from right
        addConstraint(NSLayoutConstraint(item: accessoryButton, attribute: .Bottom, relatedBy: .Equal, toItem: titleLabel, attribute: .Bottom, multiplier: 1, constant: 3))
        addConstraint(NSLayoutConstraint(item: accessoryButton, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: -16))
        
        
        //Border at bottom of the bar
        bottomBorder.backgroundColor = UIColor.whiteColor()
        bottomBorder.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bottomBorder)
        
        //Bottom = self's bottom, 0px from left, right, 1px height
        addConstraint(NSLayoutConstraint(item: bottomBorder, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: bottomBorder, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: bottomBorder, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: bottomBorder, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 1))
        
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK: - Custom methods
    
    func setTitle(title:String, accessoryButtonTitle: String, accessoryButtonHandler:() -> Void) {
        titleLabel.text = title
        accessoryButton.setTitle(accessoryButtonTitle, forState: .Normal)
        
        accessoryButtonAction = accessoryButtonHandler
    }
    
    //Opens the settings menu or closes the settings menu
    func buttonAction() {
        if let action = accessoryButtonAction {
            //If the action exists, perform it
            action()
        }
    }
}