//
//  MainEncodingView.swift
//  Pictograph
//
//  Created by Adam Boyd on 2015-10-26.
//  Copyright © 2015 Adam Boyd. All rights reserved.
//

import Foundation

private let mainFontSize: CGFloat = 20

private let bigButtonHeight: CGFloat = 50
private let buttonBorderWidth: CGFloat = 0.5

private let encryptionMargin: CGFloat = 25
private let encryptionVerticalMargin: CGFloat = 15

class MainEncodingView: UIScrollView {
    
    var contentHeight: CGFloat {
        return 15 + 260 + ((UIScreen.main.bounds.width - (2 * encryptionMargin)) / 2) + 15
    }
    
    //UI elements
    weak var elementContainer: UIView!
    weak var imageView: UIImageView!
    weak var smallTapSelectImageLabel: UILabel!
    weak var largeTapSelectImageLabel: UILabel!
    weak var shareButton: UIButton!
    weak var borderBelowImage: UIView!
    weak var encryptionLabel: UILabel!
    weak var encryptionKeyField: PictographInsetTextField!
    weak var encryptionSwitch: UISwitch!
    weak var encryptionInfoViewBorder: UIView!
    weak var encodeButton: PictographHighlightButton!
    weak var decodeButton: PictographHighlightButton!
    
    // MARK: - UIView
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.commonInit()
    }
    
    private func commonInit() {
        self.alwaysBounceVertical = true
        
        let elementContainer = UIView()
        self.elementContainer = elementContainer
        self.addSubview(elementContainer)
        self.setScrollViewContentSize(width: UIScreen.main.bounds.width)
        
        self.setUpImageView()
        
        self.setUpImageViewLabels()
        
        self.setUpShareButton()
        
        self.setUpEncryptionArea()
        
        self.setUpEncryptionAreaBorder()
        
        self.setUpEncodeButton()
        
        self.setUpDecodeButton()
    }
    
    /// Sets up how large the content size of the elements in the encoding view are
    ///
    /// - Parameter width: width to use
    func setScrollViewContentSize(width: CGFloat) {
        self.elementContainer.frame = CGRect(x: 0, y: 0, width: width, height: self.contentHeight)
        self.contentSize = CGSize(width: width, height: self.contentHeight)
    }
    
    // MARK: Adding elements
    
    private func setUpImageView() {
        let imageView = UIImageView()
        self.imageView = imageView
        
        //Image view, location for views based off this view
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.layer.borderColor = UIColor.white.cgColor
        self.imageView.layer.borderWidth = 1
        self.imageView.contentMode = .scaleAspectFill
        self.imageView.clipsToBounds = true
        self.elementContainer.addSubview(self.imageView)
        
        self.imageView.topAnchor.constraint(equalTo: self.elementContainer.topAnchor, constant: encryptionVerticalMargin).isActive = true
        self.imageView.leftAnchor.constraint(equalTo: self.elementContainer.leftAnchor, constant: encryptionMargin).isActive = true
        self.imageView.rightAnchor.constraint(equalTo: self.elementContainer.rightAnchor, constant: -encryptionMargin).isActive = true
        self.imageView.heightAnchor.constraint(equalTo: self.imageView.widthAnchor, multiplier: 0.5, constant: 0).isActive = true
    }
    
    private func setUpImageViewLabels() {
        //Border between image and buttons
        let borderBelowImage = UIView()
        self.borderBelowImage = borderBelowImage
        
        self.borderBelowImage.backgroundColor = UIColor.white
        self.borderBelowImage.translatesAutoresizingMaskIntoConstraints = false
        self.elementContainer.addSubview(self.borderBelowImage)
        
        self.borderBelowImage.topAnchor.constraint(equalTo: self.imageView.bottomAnchor, constant: encryptionVerticalMargin).isActive = true
        self.borderBelowImage.leftAnchor.constraint(equalTo: self.elementContainer.leftAnchor, constant: encryptionMargin - 10).isActive = true
        self.borderBelowImage.rightAnchor.constraint(equalTo: self.elementContainer.rightAnchor, constant: -(encryptionMargin - 10)).isActive = true
        self.borderBelowImage.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //Small select image label
        let smallTapSelectImageLabel = UILabel()
        self.smallTapSelectImageLabel = smallTapSelectImageLabel
        
        self.smallTapSelectImageLabel.textAlignment = .center
        self.smallTapSelectImageLabel.text = "Tap to Select Image"
        self.smallTapSelectImageLabel.textColor = UIColor.white
        self.smallTapSelectImageLabel.backgroundColor = UIColor.gray.withAlphaComponent(0.75)
        self.smallTapSelectImageLabel.font = UIFont.systemFont(ofSize: 12)
        self.smallTapSelectImageLabel.translatesAutoresizingMaskIntoConstraints = false
        self.elementContainer.insertSubview(self.smallTapSelectImageLabel, aboveSubview: self.imageView)
        self.smallTapSelectImageLabel.isHidden = true //Starts off hidden
        
        self.smallTapSelectImageLabel.leftAnchor.constraint(equalTo: self.imageView.leftAnchor, constant: 1).isActive = true
        self.smallTapSelectImageLabel.bottomAnchor.constraint(equalTo: self.imageView.bottomAnchor, constant: -1).isActive = true
        
        
        //Large select image label
        let largeTapSelectImageLabel = UILabel()
        self.largeTapSelectImageLabel = largeTapSelectImageLabel
        
        self.largeTapSelectImageLabel.textAlignment = .center
        self.largeTapSelectImageLabel.text = "Tap to Select Image"
        self.largeTapSelectImageLabel.textColor = UIColor.white
        self.largeTapSelectImageLabel.font = UIFont.systemFont(ofSize: 25)
        self.largeTapSelectImageLabel.translatesAutoresizingMaskIntoConstraints = false
        self.elementContainer.insertSubview(self.largeTapSelectImageLabel, belowSubview: self.imageView)
        
        self.largeTapSelectImageLabel.centerYAnchor.constraint(equalTo: self.imageView.centerYAnchor).isActive = true
        self.largeTapSelectImageLabel.centerXAnchor.constraint(equalTo: self.imageView.centerXAnchor).isActive = true
    }
    
    private func setUpShareButton() {
        let shareButton = UIButton()
        self.shareButton = shareButton
        
        self.shareButton.setImage(#imageLiteral(resourceName: "ShareIcon"), for: .normal)
        self.shareButton.layer.cornerRadius = 20
        self.shareButton.backgroundColor = .white
        self.shareButton.translatesAutoresizingMaskIntoConstraints = false
        self.shareButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        self.shareButton.isEnabled = false
        self.shareButton.imageView?.alpha = 0.5
        self.elementContainer.insertSubview(self.shareButton, aboveSubview: self.imageView)
        
        self.shareButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.shareButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        self.shareButton.rightAnchor.constraint(equalTo: self.imageView.rightAnchor, constant: 10).isActive = true
        self.shareButton.bottomAnchor.constraint(equalTo: self.imageView.bottomAnchor, constant: 10).isActive = true
    }
    
    private func setUpEncryptionArea() {
        //Label for enabling encryption, location for views based off this view
        let encryptionLabel = UILabel()
        self.encryptionLabel = encryptionLabel
        encryptionLabel.text = "Use Password"
        encryptionLabel.font = UIFont.boldSystemFont(ofSize: mainFontSize)
        encryptionLabel.textColor = UIColor.white
        encryptionLabel.translatesAutoresizingMaskIntoConstraints = false
        self.elementContainer.addSubview(encryptionLabel)
        
        //25 from left and below the image border
        self.elementContainer.addConstraint(NSLayoutConstraint(item:encryptionLabel, attribute: .left, relatedBy: .equal, toItem:self.elementContainer, attribute: .left, multiplier:1, constant:encryptionMargin))
        self.elementContainer.addConstraint(NSLayoutConstraint(item:encryptionLabel, attribute: .top, relatedBy: .equal, toItem: self.borderBelowImage, attribute: .top, multiplier:1, constant:encryptionVerticalMargin))
        
        
        //Switch for enabling encryption
        let encryptionSwitch = UISwitch()
        self.encryptionSwitch = encryptionSwitch
        encryptionSwitch.isOn = PictographDataController.shared.userEncryptionIsEnabled
        encryptionSwitch.translatesAutoresizingMaskIntoConstraints = false
        self.elementContainer.addSubview(encryptionSwitch)
        
        //50px from right, center Y = encryptionLabel's center y
        self.elementContainer.addConstraint(NSLayoutConstraint(item: encryptionSwitch, attribute: .right, relatedBy: .equal, toItem: self.elementContainer, attribute: .right, multiplier: 1, constant: -encryptionMargin))
        self.elementContainer.addConstraint(NSLayoutConstraint(item: encryptionSwitch, attribute: .centerY, relatedBy: .equal, toItem: encryptionLabel, attribute: .centerY, multiplier: 1, constant: 0))
        
        //Textfield where encryption key is stored
        let encryptionKeyField = PictographInsetTextField()
        self.encryptionKeyField = encryptionKeyField
        encryptionKeyField.alpha = PictographDataController.shared.userEncryptionIsEnabled ? 1.0 : 0.5
        encryptionKeyField.isEnabled = PictographDataController.shared.userEncryptionIsEnabled
        encryptionKeyField.isSecureTextEntry = !PictographDataController.shared.userShowPasswordOnScreen
        encryptionKeyField.backgroundColor = UIColor.white
        encryptionKeyField.font = UIFont.systemFont(ofSize: mainFontSize)
        encryptionKeyField.placeholder = "Password"
        encryptionKeyField.text = PictographDataController.shared.userEncryptionPassword
        encryptionKeyField.autocapitalizationType = .none
        encryptionKeyField.autocorrectionType = .no
        encryptionKeyField.translatesAutoresizingMaskIntoConstraints = false
        self.elementContainer.addSubview(encryptionKeyField)
        
        //50px from left, right, -80px (above) center y
        self.elementContainer.addConstraint(NSLayoutConstraint(item:encryptionKeyField, attribute: .top, relatedBy: .equal, toItem:encryptionLabel, attribute:.bottom, multiplier:1, constant:encryptionVerticalMargin))
        self.elementContainer.addConstraint(NSLayoutConstraint(item:encryptionKeyField, attribute: .left, relatedBy:.equal, toItem:self.elementContainer, attribute: .left, multiplier:1, constant:encryptionMargin))
        self.elementContainer.addConstraint(NSLayoutConstraint(item:encryptionKeyField, attribute: .right, relatedBy: .equal, toItem:self.elementContainer, attribute: .right, multiplier:1, constant:-encryptionMargin))
    }
    
    private func setUpEncryptionAreaBorder() {
        //Border between text label and switch for enabling and disabling encryption
        let encryptionInfoViewBorder = UIView()
        self.encryptionInfoViewBorder = encryptionInfoViewBorder
        encryptionInfoViewBorder.backgroundColor = UIColor.white
        encryptionInfoViewBorder.translatesAutoresizingMaskIntoConstraints = false
        self.elementContainer.addSubview(encryptionInfoViewBorder)
        
        //Halfway between the textfield and the buttons, 30px from left, right, 1px tall
        self.elementContainer.addConstraint(NSLayoutConstraint(item: encryptionInfoViewBorder, attribute: .top, relatedBy: .equal, toItem: encryptionKeyField, attribute: .bottom, multiplier: 1, constant: encryptionVerticalMargin))
        self.elementContainer.addConstraint(NSLayoutConstraint(item: encryptionInfoViewBorder, attribute: .left, relatedBy: .equal, toItem: self.elementContainer, attribute: .left, multiplier: 1, constant: encryptionMargin - 10))
        self.elementContainer.addConstraint(NSLayoutConstraint(item: encryptionInfoViewBorder, attribute: .right, relatedBy: .equal, toItem: self.elementContainer, attribute: .right, multiplier: 1, constant: -encryptionMargin + 10))
        self.elementContainer.addConstraint(NSLayoutConstraint(item: encryptionInfoViewBorder, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 1))
    }
    
    private func setUpEncodeButton() {
        let encodeButton = PictographHighlightButton()
        self.encodeButton = encodeButton
        
        encodeButton.setTitle("Hide Message or Image", for: .normal)
        encodeButton.isEnabled = false
        encodeButton.alpha = 0.5
        encodeButton.translatesAutoresizingMaskIntoConstraints = false
        
        //Setting the corner radius
        encodeButton.layer.cornerRadius = 2.0
        
        self.elementContainer.addSubview(encodeButton)
        
        //20px from border, 40px from left, right, 60px tall
        encodeButton.topAnchor.constraint(equalTo: encryptionInfoViewBorder.bottomAnchor, constant: encryptionVerticalMargin).isActive = true
        encodeButton.leftAnchor.constraint(equalTo: self.elementContainer.leftAnchor, constant: encryptionMargin).isActive = true
        encodeButton.rightAnchor.constraint(equalTo: self.elementContainer.rightAnchor, constant: -encryptionMargin).isActive = true
        self.encodeButton.heightAnchor.constraint(equalToConstant: bigButtonHeight).isActive = true
    }
    
    private func setUpDecodeButton() {
        let decodeButton = PictographHighlightButton()
        self.decodeButton = decodeButton
        
        decodeButton.setTitle("Show Message or Image", for: .normal)
        decodeButton.isEnabled = false
        decodeButton.alpha = 0.5
        decodeButton.translatesAutoresizingMaskIntoConstraints = false
        
        //Setting the corner radius
        decodeButton.layer.cornerRadius = 2.0
        
        self.elementContainer.addSubview(decodeButton)
        
        //20px from encodeButton, 40px from left, right, 60px tall
        self.decodeButton.leftAnchor.constraint(equalTo: self.encodeButton.leftAnchor).isActive = true
        self.decodeButton.rightAnchor.constraint(equalTo: self.encodeButton.rightAnchor).isActive = true
        self.decodeButton.topAnchor.constraint(equalTo: self.encodeButton.bottomAnchor, constant: encryptionVerticalMargin).isActive = true
        self.decodeButton.heightAnchor.constraint(equalToConstant: bigButtonHeight).isActive = true
    }
}
