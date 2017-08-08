//
//  PictographViewController.swift
//  Pictograph
//
//  Created by Adam Boyd on 2015-10-26.
//  Copyright © 2015 Adam Boyd. All rights reserved.
//

import Foundation
import UIKit

let mainAppColor = #colorLiteral(red: 0.862745098, green: 0, blue: 0, alpha: 1)
let mainAppColorHighlighted = mainAppColor.withAlphaComponent(0.5)

let mainAppColorNight = #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1294117647, alpha: 1)
let mainAppColorNightHighlighted = mainAppColorNight.withAlphaComponent(0.5)

class PictographViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Background color
        self.view.backgroundColor = PictographDataController.shared.userNightModeIsEnabled ? mainAppColorNight : mainAppColor
        UINavigationBar.appearance().barTintColor = PictographDataController.shared.userNightModeIsEnabled ? mainAppColorNight : mainAppColor
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view.backgroundColor = PictographDataController.shared.userNightModeIsEnabled ? mainAppColorNight : mainAppColor
        self.navigationController?.navigationBar.barTintColor = PictographDataController.shared.userNightModeIsEnabled ? mainAppColorNight : mainAppColor
    }
    
    //Creating a UINavigationController with a VC as its root view controller
    class func createWithNavigationController() -> UINavigationController {
        let this = self.init()
        let navigationController = UINavigationController(rootViewController: this)
        
        return navigationController
    }
    
}
