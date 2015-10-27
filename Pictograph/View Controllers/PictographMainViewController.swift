//
//  PictographMainViewController2.swift
//  Pictograph
//
//  Created by Adam Boyd on 2015-10-25.
//  Copyright © 2015 Adam Boyd. All rights reserved.
//

import Foundation
import UIKit
import EAIntroView
import MBProgressHUD

private let bigButtonHeight: CGFloat = 60
private let buttonBorderWidth: CGFloat = 0.5
private let mainFontSize: CGFloat = 20

private let encryptionMargin: CGFloat = 40
private let encryptionVerticalMargin: CGFloat = 40

//What we are currently doing
enum ImageOption: Int {
    case Encoding = 0, Decoding, Nothing
}

class PictographMainViewController: PictographViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, EAIntroDelegate {
    
    //Saved data
    var selectedImage: UIImage!
    var alertController: UIAlertController!
    var progressHUD: MBProgressHUD!
    var currentOption: ImageOption = .Nothing
    
    //UI elements
    var encryptionInfoViewBorder: UIView!
    var encryptionLabel: UILabel!
    var encryptionSwitch: UISwitch!
    var encryptionKeyField: PictographInsetTextField!
    var encodeButton: PictographHighlightButton!
    var decodeButton: PictographHighlightButton!
    
    //MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setting the title, button title, and action
        topBar.setTitle("Pictograph", accessoryButtonTitle: "Settings", accessoryButtonHandler: {() -> Void in
            //Open the settings view controller
            self.presentViewController(SettingsViewController(), animated: true, completion: nil)
        })
        
        
        //Encode button
        encodeButton = PictographHighlightButton()
        encodeButton.addTarget(self, action: Selector("encodeMessage"), forControlEvents: .TouchUpInside)
        encodeButton.backgroundColor = UIColor.whiteColor()
        encodeButton.setTitleColor(mainAppColor, forState: .Normal)
        encodeButton.setTitleColor(mainAppColorHighlighted, forState: .Highlighted)
        encodeButton.setTitle("Hide Message", forState: .Normal)
        encodeButton.translatesAutoresizingMaskIntoConstraints = false
        
        //Setting the border
        encodeButton.layer.borderColor = mainAppColor.CGColor
        encodeButton.layer.borderWidth = buttonBorderWidth
        
        self.view.addSubview(encodeButton)
        
        //-1px from left, 1px from bottom, 0px from center, 60px tall
        self.view.addConstraint(NSLayoutConstraint(item: encodeButton, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1, constant: 1))
        self.view.addConstraint(NSLayoutConstraint(item: encodeButton, attribute: .Left, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1, constant: -1))
        self.view.addConstraint(NSLayoutConstraint(item: encodeButton, attribute: .Right, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: encodeButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: bigButtonHeight))
        
        
        //Decode button
        decodeButton = PictographHighlightButton()
        decodeButton.addTarget(self, action: Selector("decodeMessage"), forControlEvents: .TouchUpInside)
        decodeButton.backgroundColor = UIColor.whiteColor()
        decodeButton.setTitleColor(mainAppColor, forState: .Normal)
        decodeButton.setTitleColor(mainAppColorHighlighted, forState: .Highlighted)
        decodeButton.setTitle("Reveal Message", forState: .Normal)
        decodeButton.translatesAutoresizingMaskIntoConstraints = false
        
        //Setting the border
        decodeButton.layer.borderColor = mainAppColor.CGColor
        decodeButton.layer.borderWidth = buttonBorderWidth
        
        self.view.addSubview(decodeButton)
        
        //1px from bottom, 1px from right, 0px from center, 60px tall
        self.view.addConstraint(NSLayoutConstraint(item: decodeButton, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1, constant: 1))
        self.view.addConstraint(NSLayoutConstraint(item: decodeButton, attribute: .Left, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: decodeButton, attribute: .Right, relatedBy: .Equal, toItem: self.view, attribute: .Right, multiplier: 1, constant: 1))
        self.view.addConstraint(NSLayoutConstraint(item: decodeButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: bigButtonHeight))
        
        
        //Textfield where encryption key is stored
        encryptionKeyField = PictographInsetTextField()
        let encryptionEnabled = PictographDataController.sharedController.getUserEncryptionEnabled()
        encryptionKeyField.alpha = encryptionEnabled ? 1.0 : 0.5
        encryptionKeyField.enabled = encryptionEnabled
        encryptionKeyField.delegate = self
        encryptionKeyField.backgroundColor = UIColor.whiteColor()
        encryptionKeyField.font = UIFont.systemFontOfSize(mainFontSize)
        encryptionKeyField.placeholder = "Encryption Key"
        encryptionKeyField.text = PictographDataController.sharedController.getUserEncryptionKey()
        encryptionKeyField.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(encryptionKeyField)
        
        //50px from left, right, -20px (above) center y
        self.view.addConstraint(NSLayoutConstraint(item:encryptionKeyField, attribute: .Bottom, relatedBy: .Equal, toItem:self.view, attribute:.CenterY, multiplier:1, constant:-encryptionVerticalMargin))
        self.view.addConstraint(NSLayoutConstraint(item:encryptionKeyField, attribute: .Left, relatedBy:.Equal, toItem:self.view, attribute: .Left, multiplier:1, constant:encryptionMargin))
        self.view.addConstraint(NSLayoutConstraint(item:encryptionKeyField, attribute: .Right, relatedBy: .Equal, toItem:self.view,  attribute: .Right, multiplier:1, constant:-encryptionMargin))
        
        
        
        //Label for enabling encryption
        encryptionLabel = UILabel()
        encryptionLabel.text = "Use Password"
        encryptionLabel.font = UIFont.boldSystemFontOfSize(mainFontSize)
        encryptionLabel.textColor = UIColor.whiteColor()
        encryptionLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(encryptionLabel)
        
        //0px from left, -20px (above) the top of encryptionKeyField
        self.view.addConstraint(NSLayoutConstraint(item:encryptionLabel, attribute: .Left, relatedBy: .Equal, toItem:self.view, attribute: .Left, multiplier:1, constant:encryptionMargin))
        self.view.addConstraint(NSLayoutConstraint(item:encryptionLabel, attribute: .Bottom, relatedBy: .Equal, toItem:encryptionKeyField, attribute: .Top, multiplier:1, constant:-encryptionVerticalMargin))
        
        
        
        //Switch for enabling encryption
        encryptionSwitch = UISwitch()
        encryptionSwitch.on = encryptionEnabled
        encryptionSwitch.addTarget(self, action: Selector("switchToggled:"), forControlEvents: .ValueChanged)
        encryptionSwitch.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(encryptionSwitch)
        
        //50px from right, center Y = encryptionLabel's center y
        self.view.addConstraint(NSLayoutConstraint(item: encryptionSwitch, attribute: .Right, relatedBy: .Equal, toItem: self.view, attribute: .Right, multiplier: 1, constant: -encryptionMargin))
        self.view.addConstraint(NSLayoutConstraint(item: encryptionSwitch, attribute: .CenterY, relatedBy: .Equal, toItem: encryptionLabel, attribute: .CenterY, multiplier: 1, constant: 0))
        
        
        //Border between text label and switch for enabling and disabling encryption
        encryptionInfoViewBorder = UIView()
        encryptionInfoViewBorder.backgroundColor = UIColor.whiteColor()
        encryptionInfoViewBorder.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(encryptionInfoViewBorder)
        
        //Halfway between the switch and the textfield, 40px from left, right, 1px tall
        self.view.addConstraint(NSLayoutConstraint(item: encryptionInfoViewBorder, attribute: .Bottom, relatedBy: .Equal, toItem: encryptionKeyField, attribute: .Top, multiplier: 1, constant: -encryptionVerticalMargin / 2))
        self.view.addConstraint(NSLayoutConstraint(item: encryptionInfoViewBorder, attribute: .Left, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1, constant: encryptionMargin - 10))
        self.view.addConstraint(NSLayoutConstraint(item: encryptionInfoViewBorder, attribute: .Right, relatedBy: .Equal, toItem: self.view, attribute: .Right, multiplier: 1, constant: -encryptionMargin + 10))
        self.view.addConstraint(NSLayoutConstraint(item: encryptionInfoViewBorder, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 1))
        
        
        if (setUpAndShowIntroViews()) {
            //If intro views are shown, hide UI elements
            setAlphaOfUIElementsTo(1.0)
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
        
        //Saving the text
        PictographDataController.sharedController.setUserEncryptionKey(encryptionKeyField.text!)
    }
    
    
    //MARK: - UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        //Saving the text
        PictographDataController.sharedController.setUserEncryptionKey(textField.text!)
        return false
    }
    
    
    //MARK: - EAIntroDelegate
    func introDidFinish(introView: EAIntroView!) {
        PictographDataController.sharedController.setUserFirstTimeOpeningApp(false)
        
        //Animating the views in
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            self.setAlphaOfUIElementsTo(1.0)
        })
    }
    
    
    //MARK: - Custom methods
    
    //Shows the intro views if the user hasn't opened the app and/or if we don't have authorization to use gps
    func setUpAndShowIntroViews() -> Bool {
        let introViewArray = IntroView.buildIntroViews()
        
        if introViewArray.count > 0 {
            //If there are intro views to show
            let frameRect = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height + 10) //Status bar
            let introView = EAIntroView(frame: frameRect)
            introView.pages = introViewArray
            introView.delegate = self
            introView.showInView(self.view, animateDuration: 0)
            
            //Intro view was shown, return true
            return true
        }
        
        //Intro view wasn't shown, return false
        
        return false
    }
    
    //Set the alpha of all UI elements on screen
    func setAlphaOfUIElementsTo(alpha: CGFloat) {
        
        var keyFieldAlpha = alpha;
        if alpha != 0 {
            //The key field's alpha depends on whether encryption is enabled or not
            let encryptionEnabled = PictographDataController.sharedController.getUserEncryptionEnabled()
            keyFieldAlpha = encryptionEnabled ? 1.0 : 0.5
        }
        
        topBar.alpha = alpha
        encryptionInfoViewBorder.alpha = alpha
        encryptionLabel.alpha = alpha
        encryptionSwitch.alpha = alpha
        encryptionKeyField.alpha = keyFieldAlpha
        encodeButton.alpha = alpha
        decodeButton.alpha = alpha
    }
    
    func switchToggled(sender: AnyObject) {
        let mySwitch = sender as! UISwitch
        let enabledOrDisabled = mySwitch.on
        
        //Disabling or enabling the textfield based on whether encryption is enabled
        encryptionKeyField.enabled = enabledOrDisabled
        
        //Animiating the alpha of the textfield
        UIView.animateWithDuration(0.25, animations: {() -> Void in
            self.encryptionKeyField.alpha = enabledOrDisabled ? 1.0 : 0.5
        })
        
        PictographDataController.sharedController.setUserEncryptionEnabled(enabledOrDisabled)
    }
    
    //Starting the encode process
    func encodeMessage() {
        /* True if encrytption is enabled AND the key isn't blank
        OR encrytion is disabled
        */
        if ((PictographDataController.sharedController.getUserEncryptionKey() != "" && PictographDataController.sharedController.getUserEncryptionEnabled()) || !PictographDataController.sharedController.getUserEncryptionEnabled()) {
            //Getting the photo the user wants to use
            currentOption = .Encoding
            promptUserForPhotoWithOptionForCamera(true)
        } else {
            //Show message: encryption is enabled and the key is blank
            showMessageInAlertController("Encryption is enabled but your password is blank, please enter a password.", title: "No Encryption Key")
        }
    }
    
    //Starting the decoding process
    func decodeMessage() {
        currentOption = .Decoding
        promptUserForPhotoWithOptionForCamera(false)
    }
    
    //Showing the action sheet
    func promptUserForPhotoWithOptionForCamera(showCamera: Bool) {
        if UIImagePickerController.isSourceTypeAvailable(.Camera) && showCamera {
            //Device has camera & library, show option to choose
            alertController = UIAlertController(title: "Select Picture", message: nil, preferredStyle: .ActionSheet)
            
            //Cancel action
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            //Library action
            let libraryAction = UIAlertAction(title: "Select from Library", style: .Default, handler: {(action: UIAlertAction) -> Void in
                
                //Choose photo from library, present library view controller
                let picker = self.buildImagePickerWithSourceType(.PhotoLibrary)
                self.presentViewController(picker, animated: true, completion: nil)
            })
            alertController.addAction(libraryAction)
            
            //Take photo action
            let takePhotoAction = UIAlertAction(title: "Take Photo", style: .Default, handler: {(action: UIAlertAction) -> Void in
                let picker = self.buildImagePickerWithSourceType(.Camera)
                self.presentViewController(picker, animated: true, completion: nil)
            })
            alertController.addAction(takePhotoAction)
            
            presentViewController(alertController, animated: true, completion: nil)
        
        } else {
            //Device has no camera, just show library
            let picker = buildImagePickerWithSourceType(.PhotoLibrary)
            presentViewController(picker, animated: true, completion: nil)
        
        }
    }
    
    
    //Builds a UIImagePickerController with source type
    func buildImagePickerWithSourceType(type: UIImagePickerControllerSourceType) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        picker.sourceType = type
        
        return picker
    }
    
    
    //Encoding or decoding the selected image
    func startEncodingOrDecoding() {
    
        if (currentOption == .Encoding) {
            //Encoding the image with a message, need to get message
            
            buildAndShowAlertWithTitle("Enter your message", message: nil, isSecure: false, withPlaceHolder: "Your message here", confirmHandler: {(action: UIAlertAction) -> Void in
                MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                
                //Dispatching the task after  small amount of time as per MBProgressHUD's recommendation
                let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.01 * Double(NSEC_PER_SEC)))
                dispatch_after(popTime, dispatch_get_main_queue(), {() -> Void in
                    
                    //Action that happens when confirm is hit
                    let messageField = self.alertController.textFields!.first!
                    
                    let coder = UIImageCoder()

                    //Hide the HUD
                    MBProgressHUD.hideHUDForView(self.view, animated: true)

                    do {
                        let encodedImage = try coder.encodeImage(self.selectedImage, withMessage: messageField.text!, encrypted: PictographDataController.sharedController.getUserEncryptionEnabled(), withPassword: PictographDataController.sharedController.getUserEncryptionKey())
                        //Show the share sheet if the image exists
                        self.showShareSheetWithImage(encodedImage)
                        
                    } catch let error as NSError {
                        //Catch the error
                        
                        self.showMessageInAlertController(error.localizedDescription, title: "Error")
                    }
                })
            })
            
        } else {
            //Decoding the image
            
            //No need to show HUD because this doesn't take long
            
            let coder = UIImageCoder()
            
            //Provide no password if encryption/decryption is off
            let providedPassword = encryptionSwitch.on ? encryptionKeyField.text : ""
            var error: NSError?
            let decodedMessage = coder.decodeImage(selectedImage, encryptedWithPassword: providedPassword, error: &error)
                
            if let error = error {
                showMessageInAlertController(error.localizedDescription, title: "Error Decoding")
            } else {
                //There is no error
                showMessageInAlertController(decodedMessage, title: "Hidden Message")
            }
                
        }
        
    }
    
    //Building the alert that gets the message that the user should type
    func buildAndShowAlertWithTitle(title: String, message: String?, isSecure: Bool, withPlaceHolder placeHolder:String, confirmHandler:(UIAlertAction) -> Void) {
        
        alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        //Action for confirming the message
        let confirmAction = UIAlertAction(title: "Confirm", style: .Default, handler: confirmHandler)
        confirmAction.enabled = false //Enabled or disabled based on text input
        alertController.addAction(confirmAction)
        
        //Action for cancelling
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        //Adding message field
        alertController.addTextFieldWithConfigurationHandler({(textField: UITextField) -> Void in
            textField.placeholder = placeHolder
            textField.secureTextEntry = isSecure
            
            //Confirm is only enabled if there is text
            NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue(), usingBlock: {(notification: NSNotification) -> Void in
                //Enabled when the text isn't blank
                confirmAction.enabled = (textField.text != "")
            })
            
        })
        
        presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    //Shows the share sheet with the UIImage in PNG form
    func showShareSheetWithImage(image: NSData) {
        let activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        presentViewController(activityController, animated: true, completion: nil)
    }
    
    //Shows the decoded message in an alert controller
    func showMessageInAlertController(message: String, title:String) {
        alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let dismissAction = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
        alertController.addAction(dismissAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    //MARK: - UIImagePickerControllerDelegate
    
    //User picked image
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        selectedImage = chosenImage
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        startEncodingOrDecoding()
    }
    
    //User cancelled
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        currentOption = .Nothing
    }
}