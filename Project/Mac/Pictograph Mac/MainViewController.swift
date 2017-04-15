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
    
    @IBOutlet weak var selectImageButton: NSButton!
    @IBOutlet weak var saveImageButton: NSButton!
    
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
        
        self.saveImageButton.isEnabled = imageValid
        self.showMessageButton.isEnabled = encryptionValid && imageValid
        self.hideMessageButton.isEnabled = encryptionValid && imageValid && hideMessageValid
    }
    
    // MARK: - User actions
    
    @IBAction func selectNewImageFromFileSystem(_ sender: Any) {
        
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
    
    @IBAction func saveImageAction(_ sender: Any) {
        print("User wants to save image")
    }
    
    @IBAction func encryptionEnabledChanged(_ sender: Any) {
        self.passwordTextfield.isEnabled = self.encryptionCheckbox.state == 1
    }
    
    @IBAction func hideMessageAction(_ sender: Any) {
        print("User wants to hide message")
        
        //Dispatching the task after  small amount of time as per SVProgressHUD's recommendation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            let coder = PictographImageCoder()
            
            do {
                //                let encodedImage = try coder.encodeMessage(messageToEncode, in: self.mainImageView.image!, encryptedWithPassword: PictographDataController.shared.userEncryptionPassword)
                let encodedImage = try coder.encodeMessage(self.messageTextField.stringValue, in: self.mainImageView.image!, encryptedWithPassword: nil)
                let image = NSImage(data: encodedImage)
                self.mainImageView.image = image
                
                //Alert the user
                self.showEncodedImage(image)
                
            } catch let error {
                
                //Catch the error
                self.showError(error)
            }
        }
    }

    @IBAction func showMessageAction(_ sender: Any) {
        print("User wants to show message")
        guard let image = self.mainImageView.image else {
            return
        }
        
        //No need to show HUD because this doesn't take long
        
        let coder = PictographImageCoder()
        
        //Provide no password if encryption/decryption is off
        let providedPassword = self.encryptionCheckbox.state == 1 ? self.encryptionCheckbox.stringValue : ""
        
        do {
            let decodedMessage = try coder.decodeMessage(in: image, encryptedWithPassword: providedPassword)
            
            self.messageTextField.stringValue = decodedMessage
            self.showDecodedMessage(decodedMessage)
            
        } catch let error {
            
            //Catch the error
            self.showError(error)
        }
    }
    
    // MARK: - Alerting user
    
    
    /// Shows an error to the user. If application isn't active, also sends NSUserNotification
    ///
    /// - Parameter error: error to show
    func showError(_ error: Error) {
        let alert = NSAlert()
        alert.messageText = "Error"
        alert.informativeText = error.localizedDescription
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
        
        if !NSApplication.shared().isActive {
            self.showNotificationWith(message: "Error", informativeText: error.localizedDescription)
        }
    }
    
    /// Alert user that message has been encoded in the image
    ///
    /// - Parameter image: image that the message has been encoded in
    func showEncodedImage(_ image: NSImage?) {
        let alert = NSAlert()
        alert.messageText = "Image Encoded With Message"
        alert.informativeText = "Click \"Save Image\" to save the image to disk."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Save Image")
        alert.beginSheetModal(for: self.view.window!) { [unowned self] response in
            if response != NSAlertFirstButtonReturn {
                //First button is the rightmost button. The OK button in this case.
                self.saveImageToDisk(image)
            }
        }
        
        if !NSApplication.shared().isActive {
            self.showNotificationWith(message: "Message Encoded", informativeText: nil)
        }
    }
    
    /// Informs the user that the message has been decoded from the image succesfully. If application isn't active, also sends NSUserNotification
    ///
    /// - Parameter message: decoded message
    func showDecodedMessage(_ message: String) {
        let alert = NSAlert()
        alert.messageText = "Message Decoded"
        alert.informativeText = message
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
        
        if !NSApplication.shared().isActive {
            self.showNotificationWith(message: "Message Decoded", informativeText: message)
        }
    }
    
    /// Prepares save sheet to save the image to the disk
    ///
    /// - Parameter image: image to save
    func saveImageToDisk(_ image: NSImage?) {
        
    }

    /// Creates and delivers a notification to the user
    ///
    /// - Parameters:
    ///   - message: title of the notification
    ///   - informativeText: any other text that should be shown to the user
    func showNotificationWith(message: String, informativeText: String?) {
        let notification = NSUserNotification()
        notification.title = message
        notification.informativeText = informativeText
        NSUserNotificationCenter.default.deliver(notification)
    }
    
    // MARK: - NSTextFieldDelegate
    
    /// Called every time the user typed a key in the text field
    override func controlTextDidChange(_ obj: Notification) {
        print("User entered text")
        self.checkIfValid()
    }

}

