//
//  ViewController.swift
//  Pictograph Mac
//
//  Created by Adam Boyd on 2017-01-22.
//  Copyright © 2017 Adam Boyd. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController {

    @IBOutlet weak var mainImageView: NSImageView!
    @IBOutlet weak var encryptionCheckbox: NSButton!
    @IBOutlet weak var passwordTextfield: NSTextField!
    
    @IBOutlet weak var hideMessageButton: NSButton!
    @IBOutlet weak var showMessageButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.mainImageView.wantsLayer = true
        self.mainImageView.layer?.borderColor = NSColor.black.cgColor
        self.mainImageView.layer?.borderWidth = 10
        self.mainImageView.layer?.masksToBounds = true
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func encryptionEnabledChanged(_ sender: NSButton) {
        self.passwordTextfield.isEnabled = sender.state == 1
    }
    
    @IBAction func hideMessageAction(_ sender: Any) {
        print("User wants to hide message")
    }


}

