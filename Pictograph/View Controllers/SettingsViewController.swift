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
    
    var tableView = UITableView(frame: CGRect.zero, style: .grouped)
    
    //MARK: - UIViewController
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.navigationItem.title = "Settings"
        
        //Adding the done button to the navigation bar
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.closeSettings))
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(tableView)
        
        //0px from topBar, 0px from left, right, bottom
        self.view.addConstraint(NSLayoutConstraint(item: tableView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: tableView, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: tableView, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: tableView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0))
    }
    
    //MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = PictographSettingsTableViewCell()
        
        if indexPath.row == 0 {
            cell.setTitle("Show Password", switchStartsOn: PictographDataController.sharedController.getUserShowPasswordOnScreen(), withHandler: {(enabledOrNot: Bool) -> Void in
                
                //Changing the setting for showing the password on screen
                PictographDataController.sharedController.setUserShowPasswordOnScreen(enabledOrNot)
                NotificationCenter.default.post(name: Notification.Name(rawValue: pictographShowPasswordOnScreenSettingChangedNotification), object: nil)
                print("Show password on screen: \(PictographDataController.sharedController.getUserShowPasswordOnScreen())")
            })
        } else {
            cell.setTitle("Night Mode", switchStartsOn: PictographDataController.sharedController.getUserNightModeEnabled(), withHandler: {(enabledOrNot: Bool) -> Void in
                
                //Changing the setting for showing the password on screen
                PictographDataController.sharedController.setUserDarkModeEnabled(enabledOrNot)
                NotificationCenter.default.post(name: Notification.Name(rawValue: pictographNightModeSettingChangedNotification), object: nil)
                print("Night Mode Enabled: \(PictographDataController.sharedController.getUserNightModeEnabled())")
                
                UIView.animate(withDuration: 0.5, animations: {
                    //Animate the color in
                    self.view.backgroundColor = PictographDataController.sharedController.getUserNightModeEnabled() ? mainAppColorNight : mainAppColor
                    self.navigationController?.navigationBar.barTintColor = PictographDataController.sharedController.getUserNightModeEnabled() ? mainAppColorNight : mainAppColor
                }) 
            })
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //Only 2 cells for now
        return 2
    }
    
    //Immediately deselect cell when selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return SettingsFooterView.heightForFooter()
    }
    
    //MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return SettingsFooterView()
    }
    
    func closeSettings() {
        //Dismiss settings (this view controller)
        self.dismiss(animated: true, completion: nil)
    }
    
}
