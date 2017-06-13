//
//  SettingsFooterView.swift
//  Pictograph
//
//  Created by Adam Boyd on 2015-10-26.
//  Copyright © 2015 Adam Boyd. All rights reserved.
//

import Foundation
import UIKit

private let appIconSize: CGFloat = 100
private let appIconCornerRadius: CGFloat = appIconSize/6.4
private let mainFont = UIFont.systemFont(ofSize: 18)
private let smallFont = UIFont.systemFont(ofSize: 14)

class SettingsFooterView: UIView {
    
    // The height that the footer should be
    class var heightForFooter: CGFloat {
        return 240
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //ImageView of the app icon
        let appIconView = UIImageView(image: #imageLiteral(resourceName: "IconForSettings"))
        appIconView.layer.masksToBounds = true
        appIconView.layer.cornerRadius = appIconCornerRadius
        appIconView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(appIconView)
        
        //10px below top, center x, 72px by 72px
        addConstraint(NSLayoutConstraint(item: appIconView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 10))
        addConstraint(NSLayoutConstraint(item: appIconView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: appIconView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: appIconSize))
        addConstraint(NSLayoutConstraint(item: appIconView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: appIconSize))
        
        //Title of the application
        let appTitle = UILabel(text: "Pictograph", font: mainFont)
        appTitle.translatesAutoresizingMaskIntoConstraints = false
        addSubview(appTitle)
        
        //10px below icon, center x
        addConstraint(NSLayoutConstraint(item: appTitle, attribute: .top, relatedBy: .equal, toItem: appIconView, attribute: .bottom, multiplier: 1, constant: 10))
        addConstraint(NSLayoutConstraint(item: appTitle, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        
        
        //Version of the application
        let appVersionLabel = UILabel(text: self.buildVersionString(), font: mainFont)
        appVersionLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(appVersionLabel)
        
        //10px below app title, center x
        addConstraint(NSLayoutConstraint(item: appVersionLabel, attribute: .top, relatedBy: .equal, toItem: appTitle, attribute: .bottom, multiplier: 1, constant: 5))
        addConstraint(NSLayoutConstraint(item: appVersionLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        
        
        //Made by label
        let madeByLabel = UILabel(text: "Made by Adam in SF", font: mainFont)
        madeByLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(madeByLabel)
        
        //10px below version, center x
        addConstraint(NSLayoutConstraint(item: madeByLabel, attribute: .top, relatedBy: .equal, toItem: appVersionLabel, attribute: .bottom, multiplier: 1, constant:10))
        addConstraint(NSLayoutConstraint(item: madeByLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        
        
        //Go to website button
        let goToWebsiteButton = UIButton()
        goToWebsiteButton.titleLabel!.font = mainFont
        goToWebsiteButton.setTitle("Go to Website", for: UIControlState())
        goToWebsiteButton.setTitleColor(mainAppColor, for: UIControlState())
        goToWebsiteButton.setTitleColor(mainAppColorHighlighted, for: .highlighted)
        goToWebsiteButton.addTarget(self, action: #selector(self.openWebsiteURL), for: .touchUpInside)
        goToWebsiteButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(goToWebsiteButton)
        
        //10px below made by label, center x
        addConstraint(NSLayoutConstraint(item: goToWebsiteButton, attribute: .top, relatedBy: .equal, toItem: madeByLabel, attribute: .bottom, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: goToWebsiteButton, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// Builds the string that is displayed in the app with the app version
    ///
    /// - Returns: Version <current-version> "Version 1.4.1"
    private func buildVersionString() -> String {
        //Version of the application
        var appVersion = "Version"
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            
            //Adding the actual version to the string
            appVersion += " \(version)"
        }
        return appVersion
    }
    
    //Opens my website in Safari
    @objc func openWebsiteURL() {
        PictographDataController.shared.goToWebsite()
    }
}
