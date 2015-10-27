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
private let mainFont = UIFont.systemFontOfSize(18)
private let smallFont = UIFont.systemFontOfSize(14)

class SettingsFooterView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //Icon of the application
        let appIcon = UIImage(named: "AppIcon.png")
        
        //ImageView of the app icon
        let appIconView = UIImageView(image: appIcon)
        appIconView.layer.masksToBounds = true
        appIconView.layer.cornerRadius = appIconCornerRadius
        appIconView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(appIconView)
        
        //10px below top, center x, 72px by 72px
        addConstraint(NSLayoutConstraint(item: appIconView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 10))
        addConstraint(NSLayoutConstraint(item: appIconView, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: appIconView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: appIconSize))
        addConstraint(NSLayoutConstraint(item: appIconView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: appIconSize))
        
        
        //Title of the application
        let appTitle = UILabel()
        appTitle.text = "Pictograph"
        appTitle.font = mainFont
        appTitle.translatesAutoresizingMaskIntoConstraints = false
        addSubview(appTitle)
        
        //10px below icon, center x
        addConstraint(NSLayoutConstraint(item: appTitle, attribute: .Top, relatedBy: .Equal, toItem: appIconView, attribute: .Bottom, multiplier: 1, constant: 10))
        addConstraint(NSLayoutConstraint(item: appTitle, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
        
        
        //Version of the application
        var appVersion = "Version"
        if let version = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] {
            let versionString = version as! String
            
            //Adding the actual version to the string
            appVersion += " \(versionString)"
        }
        let appVersionLabel = UILabel()
        appVersionLabel.text = appVersion
        appVersionLabel.font = smallFont
        appVersionLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(appVersionLabel)
        
        //10px below app title, center x
        addConstraint(NSLayoutConstraint(item: appVersionLabel, attribute: .Top, relatedBy: .Equal, toItem: appTitle, attribute: .Bottom, multiplier: 1, constant: 5))
        addConstraint(NSLayoutConstraint(item: appVersionLabel, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
        
        
        //Made by label
        let madeByLabel = UILabel()
        madeByLabel.text = "Made by Adam in SF"
        madeByLabel.font = mainFont
        madeByLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(madeByLabel)
        
        //10px below version, center x
        addConstraint(NSLayoutConstraint(item: madeByLabel, attribute: .Top, relatedBy: .Equal, toItem: appVersionLabel, attribute: .Bottom, multiplier: 1, constant:10))
        addConstraint(NSLayoutConstraint(item: madeByLabel, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
        
        
        //Go to website button
        let goToWebsiteButton = UIButton()
        goToWebsiteButton.titleLabel!.font = mainFont
        goToWebsiteButton.setTitle("Go to Website", forState: .Normal)
        goToWebsiteButton.setTitleColor(mainAppColor, forState: .Normal)
        goToWebsiteButton.setTitleColor(mainAppColorHighlighted, forState: .Highlighted)
        goToWebsiteButton.addTarget(self, action: Selector("openWebsiteURL"), forControlEvents: .TouchUpInside)
        goToWebsiteButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(goToWebsiteButton)
        
        //10px below made by label, center x
        addConstraint(NSLayoutConstraint(item: goToWebsiteButton, attribute: .Top, relatedBy: .Equal, toItem: madeByLabel, attribute: .Bottom, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: goToWebsiteButton, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    class func heightForFooter() -> CGFloat {
        return 240
    }
    
    //Opens my website in Safari
    func openWebsiteURL() {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://adamjboyd.com")!)
    }
}