//
//  SettingsViewController.swift
//  Pictograph
//
//  Created by Adam Boyd on 2015-10-26.
//  Copyright © 2015 Adam Boyd. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: PictographViewController {
    
    //MARK: - UIViewController
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //Setting the title, button title, and action
        topBar.setTitle("Settings", accessoryButtonTitle: "Close", accessoryButtonHandler: {() -> Void in
            //Dismiss settings (this view controller)
            self.dismissViewControllerAnimated(true, completion: nil)
        })
    }
    
}