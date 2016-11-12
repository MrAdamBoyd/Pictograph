//
//  PictographViewController.swift
//  Pictograph
//
//  Created by Adam Boyd on 2015-10-26.
//  Copyright © 2015 Adam Boyd. All rights reserved.
//

import Foundation
import UIKit

let mainAppColor = UIColor(red: 220/255.0, green: 0, blue: 0, alpha: 1)
let mainAppColorHighlighted = mainAppColor.withAlphaComponent(0.5)

let mainAppColorNight = UIColor(red:0.13, green:0.13, blue:0.13, alpha:1.0)
let mainAppColorNightHighlighted = mainAppColorNight.withAlphaComponent(0.5)

class PictographViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Background color
        self.view.backgroundColor = PictographDataController.sharedController.getUserNightModeEnabled() ? mainAppColorNight : mainAppColor
        UINavigationBar.appearance().barTintColor = PictographDataController.sharedController.getUserNightModeEnabled() ? mainAppColorNight : mainAppColor
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view.backgroundColor = PictographDataController.sharedController.getUserNightModeEnabled() ? mainAppColorNight : mainAppColor
        self.navigationController?.navigationBar.barTintColor = PictographDataController.sharedController.getUserNightModeEnabled() ? mainAppColorNight : mainAppColor
    }
    
    //Creating a UINavigationController with a VC as its root view controller
    class func createWithNavigationController() -> UINavigationController {
        let this = self.init()
        let navigationController = UINavigationController(rootViewController: this)
        
        return navigationController
    }
    
}
