//
//  MainEncodingView.swift
//  Pictograph
//
//  Created by Adam Boyd on 2015-10-26.
//  Copyright © 2015 Adam Boyd. All rights reserved.
//

import Foundation

private let mainFontSize: CGFloat = 20

private let bigButtonHeight: CGFloat = 60
private let buttonBorderWidth: CGFloat = 0.5
private let buttonCenterMargin: CGFloat = 5

private let encryptionMargin: CGFloat = 25
private let encryptionVerticalMargin: CGFloat = 20

class MainEncodingView: UIScrollView {
    
    //UI elements
    let elementContainer = UIView()
    var encodeButton = PictographHighlightButton()
    var decodeButton = PictographHighlightButton()
    var encodeImageButton = PictographHighlightButton()
    var decodeImageButton = PictographHighlightButton()
    var encryptionKeyField = PictographInsetTextField()
    var encryptionLabel = UILabel()
    var encryptionSwitch = UISwitch()
    var encryptionInfoViewBorder = UIView()
    
    //MARK: - UIView
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.alwaysBounceVertical = true
        
        let encryptionEnabled = PictographDataController.sharedController.getUserEncryptionEnabled()
        
        self.addSubview(self.elementContainer)
        self.elementContainer.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, max(UIScreen.mainScreen().bounds.height-64, 300))
        
        //Label for enabling encryption, location for views based off this view
        encryptionLabel.text = "Use Encryption"
        encryptionLabel.font = UIFont.boldSystemFontOfSize(mainFontSize)
        encryptionLabel.textColor = UIColor.whiteColor()
        encryptionLabel.translatesAutoresizingMaskIntoConstraints = false
        self.elementContainer.addSubview(encryptionLabel)
        
        //0px from left
        self.elementContainer.addConstraint(NSLayoutConstraint(item:encryptionLabel, attribute: .Left, relatedBy: .Equal, toItem:self.elementContainer, attribute: .Left, multiplier:1, constant:encryptionMargin))
        
        let screenSize = max(UIScreen.mainScreen().bounds.height, UIScreen.mainScreen().bounds.width)
        if screenSize < 1024 {
            //iPhone screen size
            //20px from top of screen
            self.elementContainer.addConstraint(NSLayoutConstraint(item:encryptionLabel, attribute: .Top, relatedBy: .Equal, toItem: self.elementContainer,  attribute: .Top, multiplier:1, constant:encryptionVerticalMargin))
        } else {
            //All other devices
            //-200px(above) center of view
            self.elementContainer.addConstraint(NSLayoutConstraint(item:encryptionLabel, attribute: .Top, relatedBy: .Equal, toItem: self.elementContainer,  attribute: .CenterY, multiplier:1, constant:-encryptionVerticalMargin * 10))
        }
        
        
        //Switch for enabling encryption
        encryptionSwitch.on = encryptionEnabled
        encryptionSwitch.translatesAutoresizingMaskIntoConstraints = false
        self.elementContainer.addSubview(encryptionSwitch)
        
        //50px from right, center Y = encryptionLabel's center y
        self.elementContainer.addConstraint(NSLayoutConstraint(item: encryptionSwitch, attribute: .Right, relatedBy: .Equal, toItem: self.elementContainer, attribute: .Right, multiplier: 1, constant: -encryptionMargin))
        self.elementContainer.addConstraint(NSLayoutConstraint(item: encryptionSwitch, attribute: .CenterY, relatedBy: .Equal, toItem: encryptionLabel, attribute: .CenterY, multiplier: 1, constant: 0))
        
        //Textfield where encryption key is stored
        encryptionKeyField.alpha = encryptionEnabled ? 1.0 : 0.5
        encryptionKeyField.enabled = encryptionEnabled
        encryptionKeyField.secureTextEntry = !PictographDataController.sharedController.getUserShowPasswordOnScreen()
        encryptionKeyField.backgroundColor = UIColor.whiteColor()
        encryptionKeyField.font = UIFont.systemFontOfSize(mainFontSize)
        encryptionKeyField.placeholder = "Encryption Password"
        encryptionKeyField.text = PictographDataController.sharedController.getUserEncryptionKey()
        encryptionKeyField.autocapitalizationType = .None
        encryptionKeyField.autocorrectionType = .No
        encryptionKeyField.translatesAutoresizingMaskIntoConstraints = false
        self.elementContainer.addSubview(encryptionKeyField)
        
        //50px from left, right, -80px (above) center y
        self.elementContainer.addConstraint(NSLayoutConstraint(item:encryptionKeyField, attribute: .Top, relatedBy: .Equal, toItem:encryptionLabel, attribute:.Bottom, multiplier:1, constant:encryptionVerticalMargin))
        self.elementContainer.addConstraint(NSLayoutConstraint(item:encryptionKeyField, attribute: .Left, relatedBy:.Equal, toItem:self.elementContainer, attribute: .Left, multiplier:1, constant:encryptionMargin))
        self.elementContainer.addConstraint(NSLayoutConstraint(item:encryptionKeyField, attribute: .Right, relatedBy: .Equal, toItem:self.elementContainer,  attribute: .Right, multiplier:1, constant:-encryptionMargin))
        
        
        //Border between text label and switch for enabling and disabling encryption
        encryptionInfoViewBorder.backgroundColor = UIColor.whiteColor()
        encryptionInfoViewBorder.translatesAutoresizingMaskIntoConstraints = false
        self.elementContainer.addSubview(encryptionInfoViewBorder)
        
        //Halfway between the textfield and the buttons, 30px from left, right, 1px tall
        self.elementContainer.addConstraint(NSLayoutConstraint(item: encryptionInfoViewBorder, attribute: .Top, relatedBy: .Equal, toItem: encryptionKeyField, attribute: .Bottom, multiplier: 1, constant: encryptionVerticalMargin))
        self.elementContainer.addConstraint(NSLayoutConstraint(item: encryptionInfoViewBorder, attribute: .Left, relatedBy: .Equal, toItem: self.elementContainer,  attribute: .Left, multiplier: 1, constant: encryptionMargin - 10))
        self.elementContainer.addConstraint(NSLayoutConstraint(item: encryptionInfoViewBorder, attribute: .Right, relatedBy: .Equal, toItem: self.elementContainer,  attribute: .Right, multiplier: 1, constant: -encryptionMargin + 10))
        self.elementContainer.addConstraint(NSLayoutConstraint(item: encryptionInfoViewBorder, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 1))
        
        
        //Encode button
        encodeButton.setTitle("Hide Message", forState: .Normal)
        encodeButton.translatesAutoresizingMaskIntoConstraints = false
        
        //Setting the corner radius
        encodeButton.layer.cornerRadius = 2.0
        
        self.elementContainer.addSubview(encodeButton)
        
        //20px from border, 40px from left, right, 60px tall
        self.elementContainer.addConstraint(NSLayoutConstraint(item: encodeButton, attribute: .Top, relatedBy: .Equal, toItem: encryptionInfoViewBorder, attribute: .Bottom, multiplier: 1, constant: encryptionVerticalMargin))
        self.elementContainer.addConstraint(NSLayoutConstraint(item: encodeButton, attribute: .Left, relatedBy: .Equal, toItem: self.elementContainer,  attribute: .Left, multiplier: 1, constant: encryptionMargin))
        self.elementContainer.addConstraint(NSLayoutConstraint(item: encodeButton, attribute: .Right, relatedBy: .Equal, toItem: self.elementContainer,  attribute: .CenterX, multiplier: 1, constant: -buttonCenterMargin))
       self.elementContainer.addConstraint(NSLayoutConstraint(item: encodeButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: bigButtonHeight))
        
        
        //Decode button
        decodeButton.setTitle("Show Message", forState: .Normal)
        decodeButton.translatesAutoresizingMaskIntoConstraints = false
        
        //Setting the corner radius
        decodeButton.layer.cornerRadius = 2.0
        
        self.elementContainer.addSubview(decodeButton)
        
        //20px from encodeButton, 40px from left, right, 60px tall
        self.elementContainer.addConstraint(NSLayoutConstraint(item: decodeButton, attribute: .Top, relatedBy: .Equal, toItem: encryptionInfoViewBorder, attribute: .Bottom, multiplier: 1, constant: encryptionVerticalMargin))
        self.elementContainer.addConstraint(NSLayoutConstraint(item: decodeButton, attribute: .Left, relatedBy: .Equal, toItem: self.elementContainer,  attribute: .CenterX, multiplier: 1, constant: buttonCenterMargin))
        self.elementContainer.addConstraint(NSLayoutConstraint(item: decodeButton, attribute: .Right, relatedBy: .Equal, toItem: self.elementContainer,  attribute: .Right, multiplier: 1, constant: -encryptionMargin))
        self.elementContainer.addConstraint(NSLayoutConstraint(item: decodeButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: bigButtonHeight))
        
        //Encode Image Button
        self.encodeImageButton.setTitle("Hide Image", forState: .Normal)
        self.encodeImageButton.translatesAutoresizingMaskIntoConstraints = false
        
        //Setting the corner radius
        self.encodeImageButton.layer.cornerRadius = 2.0
        
        self.elementContainer.addSubview(self.encodeImageButton)
        
        //20px from border, 40px from left, right, 60px tall
        self.elementContainer.addConstraint(NSLayoutConstraint(item: self.encodeImageButton, attribute: .Top, relatedBy: .Equal, toItem: self.encodeButton, attribute: .Bottom, multiplier: 1, constant: encryptionVerticalMargin))
        self.elementContainer.addConstraint(NSLayoutConstraint(item: self.encodeImageButton, attribute: .Left, relatedBy: .Equal, toItem: self.elementContainer,  attribute: .Left, multiplier: 1, constant: encryptionMargin))
        self.elementContainer.addConstraint(NSLayoutConstraint(item: self.encodeImageButton, attribute: .Right, relatedBy: .Equal, toItem: self.elementContainer,  attribute: .CenterX, multiplier: 1, constant: -buttonCenterMargin))
        self.elementContainer.addConstraint(NSLayoutConstraint(item: self.encodeImageButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: bigButtonHeight))
        
        
        //Encode Image Button
        self.decodeImageButton.setTitle("Show Image", forState: .Normal)
        self.decodeImageButton.translatesAutoresizingMaskIntoConstraints = false
        
        //Setting the corner radius
        self.decodeImageButton.layer.cornerRadius = 2.0
        
        self.elementContainer.addSubview(self.decodeImageButton)
        
        //20px from encodeImageButton, 40px from left, right, 60px tall
        self.elementContainer.addConstraint(NSLayoutConstraint(item: self.decodeImageButton, attribute: .Top, relatedBy: .Equal, toItem: self.decodeButton, attribute: .Bottom, multiplier: 1, constant: encryptionVerticalMargin))
        self.elementContainer.addConstraint(NSLayoutConstraint(item: self.decodeImageButton, attribute: .Left, relatedBy: .Equal, toItem: self.elementContainer,  attribute: .CenterX, multiplier: 1, constant: buttonCenterMargin))
        self.elementContainer.addConstraint(NSLayoutConstraint(item: self.decodeImageButton, attribute: .Right, relatedBy: .Equal, toItem: self.elementContainer,  attribute: .Right, multiplier: 1, constant: -encryptionMargin))
        self.elementContainer.addConstraint(NSLayoutConstraint(item: self.decodeImageButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: bigButtonHeight))
        
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}