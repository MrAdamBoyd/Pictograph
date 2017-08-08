//
//  PictographSettingsTableViewCell.swift
//  Pictograph
//
//  Created by Adam Boyd on 2015-10-26.
//  Copyright © 2015 Adam Boyd. All rights reserved.
//

import Foundation
import UIKit

private let leftRightMargin: CGFloat = 16

class PictographSettingsTableViewCell: UITableViewCell {
    
    var mainLabel = UILabel()
    var settingsSwitch = UISwitch()
    fileprivate var handler: ((Bool) -> Void)?
    
    // MARK: - UITableViewCell
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    
        
        //Adding the main label
        mainLabel.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(mainLabel)
        
        //Centered on Y, 16px from left
        self.contentView.addConstraint(NSLayoutConstraint(item: mainLabel, attribute: .centerY, relatedBy: .equal, toItem: self.contentView, attribute: .centerY, multiplier: 1, constant: 0))
        self.contentView.addConstraint(NSLayoutConstraint(item: mainLabel, attribute: .left, relatedBy: .equal, toItem: self.contentView, attribute: .left, multiplier: 1, constant: leftRightMargin))
        
        
        //Switch on the right of the cell
        settingsSwitch.addTarget(self, action: #selector(self.switchToggled(_:)), for: .valueChanged)
        settingsSwitch.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(settingsSwitch)
        
        //Centered on y, -16px from right
        self.contentView.addConstraint(NSLayoutConstraint(item: settingsSwitch, attribute: .centerY, relatedBy: .equal, toItem: self.contentView, attribute: .centerY, multiplier: 1, constant: 0))
        self.contentView.addConstraint(NSLayoutConstraint(item: settingsSwitch, attribute: .right, relatedBy: .equal, toItem: self.contentView, attribute: .right, multiplier: 1, constant: -leftRightMargin))
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Custom methods
    func setTitle(_ title: String, switchStartsOn isOn: Bool, withHandler handler: @escaping ((_ enabledOrNot: Bool) -> Void)) {
        mainLabel.text = title
        settingsSwitch.isOn = isOn
        
        self.handler = handler
    }
    
    //Function that is called when the switch is changed
    @objc func switchToggled(_ sender: AnyObject) {
        let mySwitch = sender as! UISwitch
        let enabledOrDisabled = mySwitch.isOn
        
        if let action = handler {
            //If the action exists, trigger it
            action(enabledOrDisabled)
        }
    }
}
