//
//  AboutViewController.swift
//  Pictograph
//
//  Created by Adam Boyd on 17/4/15.
//  Copyright © 2017 Adam Boyd. All rights reserved.
//

import Foundation
import Cocoa

class AboutViewController: NSViewController {
    
    @IBOutlet weak var versionTextField: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            self.versionTextField.stringValue = "Version \(version)"
        }
    }
    
    @IBAction func goToWebsiteButton(_ sender: Any) {
        NSWorkspace.shared().open(URL(string: "https://mradamboyd.github.io/Pictograph/")!)
    }
}
