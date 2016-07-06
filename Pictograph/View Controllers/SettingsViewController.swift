//
//  SettingsViewController.swift
//  Pictograph
//
//  Created by Adam Boyd on 2015-10-26.
//  Copyright © 2015 Adam Boyd. All rights reserved.
//

import Foundation
import UIKit

private let cellIdentifier = "PictographSettingsTableViewCellIdentifier"

class SettingsViewController: PictographViewController, UITableViewDataSource, UITableViewDelegate {
    
    var tableView = UITableView(frame: CGRectZero, style: .Grouped)
    
    //MARK: - UIViewController
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.navigationItem.title = "Settings"
        
        //Adding the done button to the navigation bar
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .Done, target: self, action: #selector(self.closeSettings))
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(tableView)
        
        //0px from topBar, 0px from left, right, bottom
        self.view.addConstraint(NSLayoutConstraint(item: tableView, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: tableView, attribute: .Left, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: tableView, attribute: .Right, relatedBy: .Equal, toItem: self.view, attribute: .Right, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: tableView, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1, constant: 0))
    }
    
    //MARK: - UITableViewDataSource
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = PictographSettingsTableViewCell()
        
        if indexPath.row == 0 {
            cell.setTitle("Show Password", switchStartsOn: PictographDataController.sharedController.getUserShowPasswordOnScreen(), withHandler: {(enabledOrNot: Bool) -> Void in
                
                //Changing the setting for showing the password on screen
                PictographDataController.sharedController.setUserShowPasswordOnScreen(enabledOrNot)
                NSNotificationCenter.defaultCenter().postNotificationName(pictographShowPasswordOnScreenSettingChangedNotification, object: nil)
                print("Show password on screen: \(PictographDataController.sharedController.getUserShowPasswordOnScreen())")
            })
        } else {
            cell.setTitle("Night Mode", switchStartsOn: PictographDataController.sharedController.getUserNightModeEnabled(), withHandler: {(enabledOrNot: Bool) -> Void in
                
                //Changing the setting for showing the password on screen
                PictographDataController.sharedController.setUserDarkModeEnabled(enabledOrNot)
                NSNotificationCenter.defaultCenter().postNotificationName(pictographNightModeSettingChangedNotification, object: nil)
                print("Night Mode Enabled: \(PictographDataController.sharedController.getUserNightModeEnabled())")
                
                UIView.animateWithDuration(0.5) {
                    //Animate the color in
                    self.view.backgroundColor = PictographDataController.sharedController.getUserNightModeEnabled() ? mainAppColorNight : mainAppColor
                    self.navigationController?.navigationBar.barTintColor = PictographDataController.sharedController.getUserNightModeEnabled() ? mainAppColorNight : mainAppColor
                }
            })
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //Only 2 cells for now
        return 2
    }
    
    //Immediately deselect cell when selected
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return SettingsFooterView.heightForFooter()
    }
    
    //MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return SettingsFooterView()
    }
    
    func closeSettings() {
        //Dismiss settings (this view controller)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}