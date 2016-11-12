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
    var encryptionKeyField = PictographInsetTextField()
    var encryptionLabel = UILabel()
    var encryptionSwitch = UISwitch()
    var encryptionInfoViewBorder = UIView()
    
    //MARK: - UIView
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.alwaysBounceVertical = true
        
        let encryptionEnabled = PictographDataController.shared.getUserEncryptionEnabled()
        
        self.addSubview(self.elementContainer)
        self.elementContainer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: max(UIScreen.main.bounds.height - 64, 300))
        
        //Label for enabling encryption, location for views based off this view
        encryptionLabel.text = "Use Encryption"
        encryptionLabel.font = UIFont.boldSystemFont(ofSize: mainFontSize)
        encryptionLabel.textColor = UIColor.white
        encryptionLabel.translatesAutoresizingMaskIntoConstraints = false
        self.elementContainer.addSubview(encryptionLabel)
        
        //0px from left
        self.elementContainer.addConstraint(NSLayoutConstraint(item:encryptionLabel, attribute: .left, relatedBy: .equal, toItem:self.elementContainer, attribute: .left, multiplier:1, constant:encryptionMargin))
        
        let screenSize = max(UIScreen.main.bounds.height, UIScreen.main.bounds.width)
        if screenSize < 1024 {
            //iPhone screen size
            //20px from top of screen
            self.elementContainer.addConstraint(NSLayoutConstraint(item:encryptionLabel, attribute: .top, relatedBy: .equal, toItem: self.elementContainer,  attribute: .top, multiplier:1, constant:encryptionVerticalMargin))
        } else {
            //All other devices
            //-200px(above) center of view
            self.elementContainer.addConstraint(NSLayoutConstraint(item:encryptionLabel, attribute: .top, relatedBy: .equal, toItem: self.elementContainer,  attribute: .centerY, multiplier:1, constant:-encryptionVerticalMargin * 10))
        }
        
        
        //Switch for enabling encryption
        encryptionSwitch.isOn = encryptionEnabled
        encryptionSwitch.translatesAutoresizingMaskIntoConstraints = false
        self.elementContainer.addSubview(encryptionSwitch)
        
        //50px from right, center Y = encryptionLabel's center y
        self.elementContainer.addConstraint(NSLayoutConstraint(item: encryptionSwitch, attribute: .right, relatedBy: .equal, toItem: self.elementContainer, attribute: .right, multiplier: 1, constant: -encryptionMargin))
        self.elementContainer.addConstraint(NSLayoutConstraint(item: encryptionSwitch, attribute: .centerY, relatedBy: .equal, toItem: encryptionLabel, attribute: .centerY, multiplier: 1, constant: 0))
        
        //Textfield where encryption key is stored
        encryptionKeyField.alpha = encryptionEnabled ? 1.0 : 0.5
        encryptionKeyField.isEnabled = encryptionEnabled
        encryptionKeyField.isSecureTextEntry = !PictographDataController.shared.getUserShowPasswordOnScreen()
        encryptionKeyField.backgroundColor = UIColor.white
        encryptionKeyField.font = UIFont.systemFont(ofSize: mainFontSize)
        encryptionKeyField.placeholder = "Encryption Password"
        encryptionKeyField.text = PictographDataController.shared.getUserEncryptionKey()
        encryptionKeyField.autocapitalizationType = .none
        encryptionKeyField.autocorrectionType = .no
        encryptionKeyField.translatesAutoresizingMaskIntoConstraints = false
        self.elementContainer.addSubview(encryptionKeyField)
        
        //50px from left, right, -80px (above) center y
        self.elementContainer.addConstraint(NSLayoutConstraint(item:encryptionKeyField, attribute: .top, relatedBy: .equal, toItem:encryptionLabel, attribute:.bottom, multiplier:1, constant:encryptionVerticalMargin))
        self.elementContainer.addConstraint(NSLayoutConstraint(item:encryptionKeyField, attribute: .left, relatedBy:.equal, toItem:self.elementContainer, attribute: .left, multiplier:1, constant:encryptionMargin))
        self.elementContainer.addConstraint(NSLayoutConstraint(item:encryptionKeyField, attribute: .right, relatedBy: .equal, toItem:self.elementContainer,  attribute: .right, multiplier:1, constant:-encryptionMargin))
        
        
        //Border between text label and switch for enabling and disabling encryption
        encryptionInfoViewBorder.backgroundColor = UIColor.white
        encryptionInfoViewBorder.translatesAutoresizingMaskIntoConstraints = false
        self.elementContainer.addSubview(encryptionInfoViewBorder)
        
        //Halfway between the textfield and the buttons, 30px from left, right, 1px tall
        self.elementContainer.addConstraint(NSLayoutConstraint(item: encryptionInfoViewBorder, attribute: .top, relatedBy: .equal, toItem: encryptionKeyField, attribute: .bottom, multiplier: 1, constant: encryptionVerticalMargin))
        self.elementContainer.addConstraint(NSLayoutConstraint(item: encryptionInfoViewBorder, attribute: .left, relatedBy: .equal, toItem: self.elementContainer,  attribute: .left, multiplier: 1, constant: encryptionMargin - 10))
        self.elementContainer.addConstraint(NSLayoutConstraint(item: encryptionInfoViewBorder, attribute: .right, relatedBy: .equal, toItem: self.elementContainer,  attribute: .right, multiplier: 1, constant: -encryptionMargin + 10))
        self.elementContainer.addConstraint(NSLayoutConstraint(item: encryptionInfoViewBorder, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 1))
        
        
        //Encode button
        encodeButton.setTitle("Hide Message", for: UIControlState())
        encodeButton.translatesAutoresizingMaskIntoConstraints = false
        
        //Setting the corner radius
        encodeButton.layer.cornerRadius = 2.0
        
        self.elementContainer.addSubview(encodeButton)
        
        //20px from border, 40px from left, right, 60px tall
        self.elementContainer.addConstraint(NSLayoutConstraint(item: encodeButton, attribute: .top, relatedBy: .equal, toItem: encryptionInfoViewBorder, attribute: .bottom, multiplier: 1, constant: encryptionVerticalMargin))
        self.elementContainer.addConstraint(NSLayoutConstraint(item: encodeButton, attribute: .left, relatedBy: .equal, toItem: self.elementContainer,  attribute: .left, multiplier: 1, constant: encryptionMargin))
        self.elementContainer.addConstraint(NSLayoutConstraint(item: encodeButton, attribute: .right, relatedBy: .equal, toItem: self.elementContainer,  attribute: .centerX, multiplier: 1, constant: -buttonCenterMargin))
       self.elementContainer.addConstraint(NSLayoutConstraint(item: encodeButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: bigButtonHeight))
        
        
        //Decode button
        decodeButton.setTitle("Show Message", for: UIControlState())
        decodeButton.translatesAutoresizingMaskIntoConstraints = false
        
        //Setting the corner radius
        decodeButton.layer.cornerRadius = 2.0
        
        self.elementContainer.addSubview(decodeButton)
        
        //20px from encodeButton, 40px from left, right, 60px tall
        self.elementContainer.addConstraint(NSLayoutConstraint(item: decodeButton, attribute: .top, relatedBy: .equal, toItem: encryptionInfoViewBorder, attribute: .bottom, multiplier: 1, constant: encryptionVerticalMargin))
        self.elementContainer.addConstraint(NSLayoutConstraint(item: decodeButton, attribute: .left, relatedBy: .equal, toItem: self.elementContainer,  attribute: .centerX, multiplier: 1, constant: buttonCenterMargin))
        self.elementContainer.addConstraint(NSLayoutConstraint(item: decodeButton, attribute: .right, relatedBy: .equal, toItem: self.elementContainer,  attribute: .right, multiplier: 1, constant: -encryptionMargin))
        self.elementContainer.addConstraint(NSLayoutConstraint(item: decodeButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: bigButtonHeight))
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
