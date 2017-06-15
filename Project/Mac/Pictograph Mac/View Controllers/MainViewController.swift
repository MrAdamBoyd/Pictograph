//
//  ViewController.swift
//  Pictograph Mac
//
//  Created by Adam Boyd on 2017-01-22.
//  Copyright © 2017 Adam Boyd. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController, NSTextFieldDelegate, DraggingDelegate {

    @IBOutlet weak var mainImageView: NSImageView!
    @IBOutlet weak var encryptionCheckbox: NSButton!
    @IBOutlet weak var passwordTextfield: NSTextField!
    
    @IBOutlet weak var hideMessageButton: NSButton!
    @IBOutlet weak var showMessageButton: NSButton!
    @IBOutlet weak var messageTextField: NSTextField!
    
    @IBOutlet weak var imageSelectLabel: NSTextField!
    @IBOutlet weak var selectImageButton: NSButton!
    @IBOutlet weak var saveImageButton: NSButton!
    @IBOutlet weak var dragAndDropView: DragAndDropView!
    
    var imageSelectPanelOpen: Bool = false
    
    var helpWindowController: NSWindowController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let clickGR = NSClickGestureRecognizer(target: self, action: #selector(self.selectNewImageFromFileSystem))
        self.dragAndDropView.addGestureRecognizer(clickGR)
        
        self.messageTextField.delegate = self
        
        self.checkIfValid()
        
        //This is impossible to figure out... why?
        self.dragAndDropView.registerForDraggedTypes([NSPasteboard.PasteboardType(rawValue: kUTTypeFileURL as String)])
        self.dragAndDropView.delegate = self
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    /// Enables or disables the hide and show message buttons based on the state
    func checkIfValid() {
        //Valid if encryption disabled OR encryption enabled and textfield isn't empty
        let encryptionValid = self.encryptionCheckbox.state == .off || (self.encryptionCheckbox.state == .on && !self.passwordTextfield.stringValue.isEmpty)
    
        let imageValid = self.mainImageView.image != nil
        
        let hideMessageValid = !self.messageTextField.stringValue.isEmpty
        
        self.imageSelectLabel.isHidden = imageValid
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
        panel.allowedFileTypes = ["jpg", "JPG", "png", "PNG", "jpeg", "JPEG", "tiff", "TIFF"]
        panel.beginSheetModal(for: self.view.window!) { [unowned self] result in
            self.imageSelectPanelOpen = false
            if let fileUrl = panel.url, result == .OK {
                guard let image = NSImage(contentsOf: fileUrl) else { return }
                
                self.mainImageView.image = image
            }
            
            self.checkIfValid()
        }
    }
    
    @IBAction func saveImageAction(_ sender: Any) {
        print("User wants to save image")
        guard let data = self.mainImageView.image?.tiffRepresentation else { return }
        
        self.saveImageToDisk(data)
    }
    
    @IBAction func encryptionEnabledChanged(_ sender: Any) {
        self.passwordTextfield.isEnabled = self.encryptionCheckbox.state == .on
    }
    
    @IBAction func hideMessageAction(_ sender: Any) {
        print("User wants to hide message")
        
        /// Alert that lets the user know the message is encoding
        let alert = NSAlert()
        alert.messageText = "Encoding..."
        let spinner = NSProgressIndicator()
        spinner.style = .spinning
        spinner.startAnimation(self)
        spinner.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        alert.accessoryView = spinner
        alert.addButton(withTitle: "Cancel")
        
        let coder = PictographImageCoder()
        
        let queue = DispatchQueue(label: "encoding", qos: .background)
        
        queue.async {
            do {
                //Provide no password if encryption/decryption is off
                let providedPassword = self.encryptionCheckbox.state == .on ? self.passwordTextfield.stringValue : ""
                
                let encodedImage = try coder.encode(message: self.messageTextField.stringValue, in: self.mainImageView.image!, encryptedWithPassword: providedPassword)
                let image = NSImage(data: encodedImage)
                
                //Hide the sheet
                DispatchQueue.main.async {
                    self.view.window?.endSheet(alert.window)
                    
                    if !coder.isCancelled {
                        //If the operation wasn't cancelled, set the image
                        self.mainImageView.image = image
                        
                        //Then wait 1 second before showing the user that the message is done encoding
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            //Alert the user
                            self.showEncodedImage(encodedImage)
                        }
                    }
                }
            
            } catch let error {
                
                //Catch the error
                self.showError(error)
            }
        }
        
        //Show the loading modal
        alert.beginSheetModal(for: self.view.window!) { response in
            if response == NSApplication.ModalResponse.alertFirstButtonReturn {
                //If the cancel button is clicked, cancel the operation
                coder.isCancelled = true
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
        let providedPassword = self.encryptionCheckbox.state == .on ? self.passwordTextfield.stringValue : ""
        
        var hiddenString: NSString?
        var hiddenImage: NSImage?
        var error: NSError?
        coder.decode(image, encryptedWithPassword: providedPassword, hiddenStringPointer: &hiddenString, hiddenImagePointer: &hiddenImage, error: &error)
        
        guard error == nil else {
            self.showError(error!)
            return
        }
        
        if let decodedMessage = hiddenString {
            
            self.messageTextField.stringValue = decodedMessage as String
            self.showDecodedMessage(decodedMessage as String)
            
        } else if let decodedImage = hiddenImage {
            
            //TODO: this
            
        }
    }
    
    @IBAction func helpButtonAction(_ sender: Any) {
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        guard let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "helpWindow")) as? NSWindowController else { return }
        self.helpWindowController = windowController
        self.helpWindowController?.window?.makeKeyAndOrderFront(self)
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
        
        if !NSApplication.shared.isActive {
            self.showNotificationWith(message: "Error", informativeText: error.localizedDescription)
        }
    }
    
    /// Alert user that message has been encoded in the image
    ///
    /// - Parameter image: image that the message has been encoded in
    func showEncodedImage(_ image: Data?) {
        let alert = NSAlert()
        alert.messageText = "Image Encoded With Message"
        alert.informativeText = "Click \"Save Image\" to save the image to disk."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Save Image")
        alert.beginSheetModal(for: self.view.window!) { [unowned self] response in
            if response != NSApplication.ModalResponse.alertFirstButtonReturn {
                //First button is the rightmost button. The OK button in this case.
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    //Wait 1 second
                    self.saveImageToDisk(image)
                }
            }
        }
        
        if !NSApplication.shared.isActive {
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
        
        if !NSApplication.shared.isActive {
            self.showNotificationWith(message: "Message Decoded", informativeText: message)
        }
    }
    
    /// Prepares save sheet to save the image to the disk
    ///
    /// - Parameter image: image to save
    func saveImageToDisk(_ image: Data?) {
        print("Saving image to disk")
        let panel = NSSavePanel()
        panel.nameFieldStringValue = ""
        panel.allowedFileTypes = ["png"]
        panel.allowsOtherFileTypes = false
        panel.beginSheetModal(for: self.view.window!) { [unowned self] result in
            if result == .OK {
                guard let filePath = panel.url else { return }
                do {
                    try image?.write(to: filePath)
                } catch let error {
                    self.showError(error)
                }
            }
        }
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
    
    // MARK: - DraggingDelegate
    
    func userDraggedFile(_ file: URL?) {
        if let url = file, let image = NSImage(contentsOf: url) {
            self.mainImageView.image = image
            self.checkIfValid()
        }
    }

}
