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
    var accessoryButtonAction: (() -> Void)?
    
    //MARK: - UIView
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //Adding the app title to the top of the screen
        titleLabel.font = UIFont.boldSystemFontOfSize(titleFontSize)
        titleLabel.textColor = UIColor.whiteColor()
        self.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .Center
        
        //Centered on y, left & right by 65px
        self.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: titleYOffset))
        self.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: titleLeftRightOffset))
        self.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: -titleLeftRightOffset))
        
        
        //Settings button
        accessoryButton.addTarget(self, action: Selector("buttonAction"), forControlEvents: .TouchUpInside)
        accessoryButton.setTitleColor(UIColor.whiteColor().colorWithAlphaComponent(0.5), forState: .Highlighted)
        accessoryButton.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(accessoryButton)
        
        //Bottom = titleLabel.bottom + 3, 15px from right
        self.addConstraint(NSLayoutConstraint(item: accessoryButton, attribute: .Bottom, relatedBy: .Equal, toItem: titleLabel, attribute: .Bottom, multiplier: 1, constant: 3))
        self.addConstraint(NSLayoutConstraint(item: accessoryButton, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: -15))
        
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