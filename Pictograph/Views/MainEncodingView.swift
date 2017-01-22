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
    let imageView = UIImageView()
    let smallTapSelectImageLabel = UILabel()
    let largeTapSelectImageLabel = UILabel()
    let borderBelowImage = UIView()
    let encryptionLabel = UILabel()
    let encryptionKeyField = PictographInsetTextField()
    let encryptionSwitch = UISwitch()
    let encryptionInfoViewBorder = UIView()
    let encodeButton = PictographHighlightButton()
    let decodeButton = PictographHighlightButton()
    
    //MARK: - UIView
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.alwaysBounceVertical = true
        
        self.addSubview(self.elementContainer)
        self.elementContainer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: max(UIScreen.main.bounds.height - 64, 300))
        
        //Image view, location for views based off this view
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.layer.borderColor = UIColor.white.cgColor
        self.imageView.layer.borderWidth = 1
        self.elementContainer.addSubview(self.imageView)
        
        //Near top
        let screenSize = max(UIScreen.main.bounds.height, UIScreen.main.bounds.width)
        if screenSize < 1024 {
            //iPhone screen size
            //20px from top of screen
            self.imageView.topAnchor.constraint(equalTo: self.elementContainer.topAnchor, constant: encryptionVerticalMargin).isActive = true
        } else {
            //All other devices
            //-300px(above) center of view
            self.imageView.topAnchor.constraint(equalTo: self.elementContainer.centerYAnchor, constant: -encryptionVerticalMargin * 15).isActive = true
        }
        self.imageView.leftAnchor.constraint(equalTo: self.elementContainer.leftAnchor, constant: encryptionMargin).isActive = true
        self.imageView.rightAnchor.constraint(equalTo: self.elementContainer.rightAnchor, constant: -encryptionMargin).isActive = true
        self.imageView.heightAnchor.constraint(equalTo: self.imageView.widthAnchor, multiplier: 0.5, constant: 0).isActive = true
        
        //Border between image and buttons
        self.borderBelowImage.backgroundColor = UIColor.white
        self.borderBelowImage.translatesAutoresizingMaskIntoConstraints = false
        self.elementContainer.addSubview(self.borderBelowImage)
        
        self.borderBelowImage.topAnchor.constraint(equalTo: self.imageView.bottomAnchor, constant: encryptionVerticalMargin).isActive = true
        self.borderBelowImage.leftAnchor.constraint(equalTo: self.elementContainer.leftAnchor, constant: encryptionMargin - 10).isActive = true
        self.borderBelowImage.rightAnchor.constraint(equalTo: self.elementContainer.rightAnchor, constant: -(encryptionMargin - 10)).isActive = true
        self.borderBelowImage.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //Small select image label
        self.smallTapSelectImageLabel.textAlignment = .center
        self.smallTapSelectImageLabel.text = "Tap to Select Image"
        self.smallTapSelectImageLabel.textColor = UIColor.white
        self.smallTapSelectImageLabel.backgroundColor = UIColor.gray.withAlphaComponent(0.75)
        self.smallTapSelectImageLabel.font = UIFont.systemFont(ofSize: 12)
        self.smallTapSelectImageLabel.translatesAutoresizingMaskIntoConstraints = false
        self.elementContainer.insertSubview(self.smallTapSelectImageLabel, aboveSubview: self.imageView)
        self.smallTapSelectImageLabel.isHidden = true //Starts off hidden
        
        self.smallTapSelectImageLabel.rightAnchor.constraint(equalTo: self.imageView.rightAnchor, constant: -1).isActive = true
        self.smallTapSelectImageLabel.bottomAnchor.constraint(equalTo: self.imageView.bottomAnchor, constant: -1).isActive = true
        
        
        //Large select image label
        self.largeTapSelectImageLabel.textAlignment = .center
        self.largeTapSelectImageLabel.text = "Tap to Select Image"
        self.largeTapSelectImageLabel.textColor = UIColor.white
        self.largeTapSelectImageLabel.font = UIFont.systemFont(ofSize: 25)
        self.largeTapSelectImageLabel.translatesAutoresizingMaskIntoConstraints = false
        self.elementContainer.insertSubview(self.largeTapSelectImageLabel, belowSubview: self.imageView)
        
        self.largeTapSelectImageLabel.centerYAnchor.constraint(equalTo: self.imageView.centerYAnchor).isActive = true
        self.largeTapSelectImageLabel.centerXAnchor.constraint(equalTo: self.imageView.centerXAnchor).isActive = true
        
        //Label for enabling encryption, location for views based off this view
        encryptionLabel.text = "Use Encryption"
        encryptionLabel.font = UIFont.boldSystemFont(ofSize: mainFontSize)
        encryptionLabel.textColor = UIColor.white
        encryptionLabel.translatesAutoresizingMaskIntoConstraints = false
        self.elementContainer.addSubview(encryptionLabel)
        
        
        //25 from left and below the image border
        self.elementContainer.addConstraint(NSLayoutConstraint(item:encryptionLabel, attribute: .left, relatedBy: .equal, toItem:self.elementContainer, attribute: .left, multiplier:1, constant:encryptionMargin))
        self.elementContainer.addConstraint(NSLayoutConstraint(item:encryptionLabel, attribute: .top, relatedBy: .equal, toItem: self.borderBelowImage,  attribute: .top, multiplier:1, constant:encryptionVerticalMargin))
        
        
        //Switch for enabling encryption
        encryptionSwitch.isOn = PictographDataController.shared.userEncryptionIsEnabled
        encryptionSwitch.translatesAutoresizingMaskIntoConstraints = false
        self.elementContainer.addSubview(encryptionSwitch)
        
        //50px from right, center Y = encryptionLabel's center y
        self.elementContainer.addConstraint(NSLayoutConstraint(item: encryptionSwitch, attribute: .right, relatedBy: .equal, toItem: self.elementContainer, attribute: .right, multiplier: 1, constant: -encryptionMargin))
        self.elementContainer.addConstraint(NSLayoutConstraint(item: encryptionSwitch, attribute: .centerY, relatedBy: .equal, toItem: encryptionLabel, attribute: .centerY, multiplier: 1, constant: 0))
        
        //Textfield where encryption key is stored
        encryptionKeyField.alpha = PictographDataController.shared.userEncryptionIsEnabled ? 1.0 : 0.5
        encryptionKeyField.isEnabled = PictographDataController.shared.userEncryptionIsEnabled
        encryptionKeyField.isSecureTextEntry = !PictographDataController.shared.userShowPasswordOnScreen
        encryptionKeyField.backgroundColor = UIColor.white
        encryptionKeyField.font = UIFont.systemFont(ofSize: mainFontSize)
        encryptionKeyField.placeholder = "Encryption Password"
        encryptionKeyField.text = PictographDataController.shared.userEncryptionPassword
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
