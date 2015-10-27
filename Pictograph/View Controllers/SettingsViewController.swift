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
        
        //Setting the title, button title, and action
        topBar.setTitle("Settings", accessoryButtonTitle: "Close", accessoryButtonHandler: {() -> Void in
            //Dismiss settings (this view controller)
            self.dismissViewControllerAnimated(true, completion: nil)
        })
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(tableView)
        
        //0px from topBar, 0px from left, right, bottom
        self.view.addConstraint(NSLayoutConstraint(item: tableView, attribute: .Top, relatedBy: .Equal, toItem: topBar, attribute: .Bottom, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: tableView, attribute: .Left, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: tableView, attribute: .Right, relatedBy: .Equal, toItem: self.view, attribute: .Right, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: tableView, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1, constant: 0))
    }
    
    //MARK: - UITableViewDataSource
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = PictographSettingsTableViewCell()
        
        cell.setTitle("Show Password", switchStartsOn: false, withHandler: {(enabledOrNot: Bool) -> Void in
            print("\(enabledOrNot)")
        })
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return SettingsFooterView.heightForFooter()
    }
    
    //MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return SettingsFooterView()
    }
    
}