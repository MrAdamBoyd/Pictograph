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
let mainAppColorHighlighted = mainAppColor.colorWithAlphaComponent(0.5)

class PictographViewController: UIViewController {
    
    var topBar: PictographTopBarView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Background color
        self.view.backgroundColor = mainAppColor
        
        //Nav bar
        topBar = PictographTopBarView()
        topBar.backgroundColor = mainAppColor
        topBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topBar)
        
        //10px from top, 0px from left & right, 44px height
        self.view.addConstraint(NSLayoutConstraint(item: topBar, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1, constant: 20))
        self.view.addConstraint(NSLayoutConstraint(item: topBar, attribute: .Left, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: topBar, attribute: .Right, relatedBy: .Equal, toItem: self.view, attribute: .Right, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: topBar, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 44))
    
    }
    
    //White status bar text
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
}