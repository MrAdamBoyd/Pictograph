//
//  ViewController.swift
//  Pictograph Mac
//
//  Created by Adam Boyd on 2017-01-22.
//  Copyright © 2017 Adam Boyd. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController, NSTextFieldDelegate {

    @IBOutlet weak var mainImageView: NSImageView!
    @IBOutlet weak var encryptionCheckbox: NSButton!
    @IBOutlet weak var passwordTextfield: NSTextField!
    
    @IBOutlet weak var hideMessageButton: NSButton!
    @IBOutlet weak var showMessageButton: NSButton!
    @IBOutlet weak var messageTextField: NSTextField!
    
    
    var imageSelectPanelOpen: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.mainImageView.wantsLayer = true
        self.mainImageView.layer?.borderColor = NSColor.black.cgColor
        self.mainImageView.layer?.borderWidth = 2
        self.mainImageView.layer?.masksToBounds = true
        
        let clickGR = NSClickGestureRecognizer(target: self, action: #selector(self.selectNewImageFromFileSystem))
        self.mainImageView.addGestureRecognizer(clickGR)
        
        self.messageTextField.delegate = self
        
        self.checkIfValid()
        
        //LOOK AT THIS::::::!!!!!!!!!!!!!!!!
        //https://www.raywenderlich.com/136272/drag-and-drop-tutorial-for-macos
        //FOR DRAGGING
        //ALSO ONLY INCLUDE IMAGES IN NSOPENPANEL
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    /// Enables or disables the hide and show message buttons based on the state
    func checkIfValid() {
        //Valid if encryption disabled OR encryption enabled and textfield isn't empty
        let encryptionValid = self.encryptionCheckbox.state == 0 || (self.encryptionCheckbox.state == 1 && !self.passwordTextfield.stringValue.isEmpty)
    
        let imageValid = self.mainImageView.image != nil
        
        let hideMessageValid = !self.messageTextField.stringValue.isEmpty
        
        self.showMessageButton.isEnabled = encryptionValid && imageValid
        self.hideMessageButton.isEnabled = encryptionValid && imageValid && hideMessageValid
    }
    
    // MARK: - User actions
    
    func selectNewImageFromFileSystem() {
        
        guard !self.imageSelectPanelOpen else { return }
        
        self.imageSelectPanelOpen = true
        
        print("Getting image")
        let panel = NSOpenPanel()
        panel.begin() { result in
            self.imageSelectPanelOpen = false
            if let fileUrl = panel.url, result == NSFileHandlingPanelOKButton {
                guard let image = NSImage(contentsOf: fileUrl) else { return }
                
                self.mainImageView.image = image
            }
            
            self.checkIfValid()
        }
    }
    
    @IBAction func encryptionEnabledChanged(_ sender: Any) {
        self.passwordTextfield.isEnabled = self.encryptionCheckbox.state == 1
    }
    
    @IBAction func hideMessageAction(_ sender: Any) {
        print("User wants to hide message")
        
        //Dispatching the task after  small amount of time as per SVProgressHUD's recommendation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            let coder = UIImageCoder()
            
            do {
                //                let encodedImage = try coder.encodeMessage(messageToEncode, in: self.mainImageView.image!, encryptedWithPassword: PictographDataController.shared.userEncryptionPassword)
                let encodedImage = try coder.encodeMessage(self.messageTextField.stringValue, in: self.mainImageView.image!, encryptedWithPassword: nil)
                self.mainImageView.image = NSImage(data: encodedImage)
                //Show the share sheet if the image exists
                //                self.showShareSheetWithImage(encodedImage)
                
            } catch let error {
                
                //Catch the error
                //                self.showMessageInAlertController("Error", message: error.localizedDescription)
            }
        }
    }

    @IBAction func showMessageAction(_ sender: Any) {
        print("User wants to show message")
    }
    
    // MARK: - NSTextFieldDelegate
    
    /// Called every time the user typed a key in the text field
    override func controlTextDidChange(_ obj: Notification) {
        print("User entered text")
        self.checkIfValid()
    }

}

