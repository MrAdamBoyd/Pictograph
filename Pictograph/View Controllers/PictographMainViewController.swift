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
    let mainEncodeView = MainEncodingView()
    
    //MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setting the title, button title, and action
        topBar.setTitle("Pictograph", accessoryButtonTitle: "Settings", accessoryButtonHandler: {() -> Void in
            //Open the settings view controller
            
            let settings = SettingsViewController()
            
            if  UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Pad {
                //On an iPad, show the popover from the button
                settings.modalPresentationStyle = .Popover
                settings.popoverPresentationController!.sourceView = self.topBar.accessoryButton
                //Presenting it from the middle of the encode button
                settings.popoverPresentationController!.sourceRect = CGRectMake(self.topBar.accessoryButton.frame.width / 2, self.topBar.accessoryButton.frame.height, 0, 0)
                settings.popoverPresentationController!.backgroundColor = mainAppColor
            }
            
            self.presentViewController(settings, animated: true, completion: nil)
        })
        
        //Adding all the UI elements to the screen
        mainEncodeView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(mainEncodeView)
        
        //0px from bottom of topBar, 0px from left, right, bottom
        self.view.addConstraint(NSLayoutConstraint(item: mainEncodeView, attribute: .Top, relatedBy: .Equal, toItem: topBar, attribute: .Bottom, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: mainEncodeView, attribute: .Left, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: mainEncodeView, attribute: .Right, relatedBy: .Equal, toItem: self.view, attribute: .Right, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: mainEncodeView, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1, constant: 0))
        
        //Setting up the actions for the elements
        mainEncodeView.encodeButton.addTarget(self, action: Selector("encodeMessage"), forControlEvents: .TouchUpInside)
        mainEncodeView.decodeButton.addTarget(self, action: Selector("decodeMessage"), forControlEvents: .TouchUpInside)
        mainEncodeView.encryptionKeyField.delegate = self
        mainEncodeView.encryptionSwitch.addTarget(self, action: Selector("switchToggled:"), forControlEvents: .ValueChanged)
        
        
        if (setUpAndShowIntroViews()) {
            //If intro views are shown, hide UI elements
            setAlphaOfUIElementsTo(0)
        }
        
        //Setting up the notifications for the settings
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("showPasswordOnScreenChanged"), name: pictographShowPasswordOnScreenSettingChangedNotification, object: nil)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
        
        //Saving the text
        PictographDataController.sharedController.setUserEncryptionKey(mainEncodeView.encryptionKeyField.text!)
    }
    
    //For NSNotificationCenter
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
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
        topBar.alpha = alpha
        mainEncodeView.alpha = alpha
    }
    
    func switchToggled(sender: AnyObject) {
        let mySwitch = sender as! UISwitch
        let enabledOrDisabled = mySwitch.on
        
        //Disabling or enabling the textfield based on whether encryption is enabled
        mainEncodeView.encryptionKeyField.enabled = enabledOrDisabled
        
        //Animiating the alpha of the textfield
        UIView.animateWithDuration(0.25, animations: {() -> Void in
            self.mainEncodeView.encryptionKeyField.alpha = enabledOrDisabled ? 1.0 : 0.5
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
            let providedPassword = mainEncodeView.encryptionSwitch.on ? mainEncodeView.encryptionKeyField.text : ""
            
            do {
                let decodedMessage = try coder.decodeMessageInImage(selectedImage, encryptedWithPassword: providedPassword)
                //Show the message if it was successfully decoded
                showMessageInAlertController(decodedMessage, title: "Hidden Message")
                
            } catch let error as NSError {
                //Catch the error
                
                showMessageInAlertController(error.localizedDescription, title: "Error Decoding")
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
        
        if  UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Pad {
            //On an iPad, show the popover from the button
            activityController.modalPresentationStyle = .Popover
            activityController.popoverPresentationController!.sourceView = mainEncodeView.encodeButton
            //Presenting it from the middle of the encode button
            activityController.popoverPresentationController!.sourceRect = CGRectMake(mainEncodeView.encodeButton.frame.width / 2, mainEncodeView.encodeButton.frame.height / 2, 0, 0)
        }
        
        //Showing the share sheet
        presentViewController(activityController, animated: true, completion: nil)
    }
    
    //Shows the decoded message in an alert controller
    func showMessageInAlertController(message: String, title:String) {
        alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let dismissAction = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
        alertController.addAction(dismissAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    //MARK: - Methods for when the settings change
    
    func showPasswordOnScreenChanged() {
        //Set the opposite of what it currently is
        mainEncodeView.encryptionKeyField.secureTextEntry = !mainEncodeView.encryptionKeyField.secureTextEntry
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