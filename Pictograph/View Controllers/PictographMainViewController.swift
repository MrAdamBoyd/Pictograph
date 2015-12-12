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
import PromiseKit

//What we are currently doing
enum PictographAction: Int {
    case EncodingMessage = 0, DecodingMessage
}

class PictographMainViewController: PictographViewController, UINavigationControllerDelegate, UITextFieldDelegate, EAIntroDelegate {
    
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
                //Presenting it from the middle of the settings button
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
        mainEncodeView.encodeButton.addTarget(self, action: Selector("startEncodeProcess"), forControlEvents: .TouchUpInside)
        mainEncodeView.decodeButton.addTarget(self, action: Selector("startDecodeProcess"), forControlEvents: .TouchUpInside)
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
    func startEncodeProcess() {
        /* True if encrytption is enabled AND the key isn't blank
        OR encrytion is disabled
        */
        if ((PictographDataController.sharedController.getUserEncryptionKeyString() != "" && PictographDataController.sharedController.getUserEncryptionEnabled()) || !PictographDataController.sharedController.getUserEncryptionEnabled()) {
            
            let getMessageController = self.buildGetMessageController("Enter your message", message: nil, isSecure: false, withPlaceHolder: "Your message here")
            var userImage: UIImage!
            
            //Getting the photo the user wants to use
            getPhotoForEncodingOrDecoding(true).then { image in
                
                //Saving the image first
                userImage = image
                
            }.then { image in
                
                //Getting the message from the user
                return self.promiseViewController(getMessageController)
            
            }.then { alert in
                    
                //Encoding the message in the image
                self.encodeMessage(getMessageController.textFields!.first!.text!, inImage: userImage)
                    
            }
            
        } else {
            //Show message: encryption is enabled and the key is blank
            showMessageInAlertController("No Encryption Key", message: "Encryption is enabled but your password is blank, please enter a password.")
        }
    }
    
    //Starting the decoding process
    func startDecodeProcess() {
        if ((PictographDataController.sharedController.getUserEncryptionKeyString() != "" && PictographDataController.sharedController.getUserEncryptionEnabled()) || !PictographDataController.sharedController.getUserEncryptionEnabled()) {
            
            //If the user has encryption enabled and the password isn't blank or encryption is not enabled
            getPhotoForEncodingOrDecoding(false).then { image in
                //Start encoding or decoding when the image has been picked
                //self.encodeOrDecodeImage(image, userAction: .DecodingMessage, messageToEncode: nil)
                self.decodeMessageInImage(image)
            }
        } else {
            //Show message: encryption is enabled and the key is blank
            showMessageInAlertController("No Encryption Key", message: "Encryption is enabled but your password is blank, please enter a password.")
        }
    }
    
    //Showing the action sheet
    func getPhotoForEncodingOrDecoding(showCamera: Bool) -> Promise<UIImage> {
        if UIImagePickerController.isSourceTypeAvailable(.Camera) && showCamera {
            //Device has camera & library, show option to choose
           
            //If the device is an iPad, popup in the middle of screen
            let alertStyle:UIAlertControllerStyle = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Pad) ? .Alert : .ActionSheet
            
            //Building the picker to choose the type of input
            let imagePopup = PMKAlertController(title: "Select Picture", message: nil, preferredStyle: alertStyle)
            imagePopup.addActionWithTitle("Select from Library")
            let takePhotoPickerAction = imagePopup.addActionWithTitle("Take Photo") //Saving the take photo action so we can show the proper picker later
            imagePopup.addActionWithTitle("Cancel", style: .Cancel)

            return promiseViewController(imagePopup).then { action in
                var pickerType = UIImagePickerControllerSourceType.PhotoLibrary

                if action == takePhotoPickerAction {
                    //If the user chose to use the camera
                    pickerType = .Camera
                }

                let picker = self.buildImagePickerWithSourceType(pickerType)

                return self.promiseViewController(picker)
            }
        
        } else {
            //Device has no camera, just show library
            let picker = buildImagePickerWithSourceType(.PhotoLibrary)
            
            return promiseViewController(picker)
        }
    }
    
    //Builds a UIImagePickerController with source type
    func buildImagePickerWithSourceType(type: UIImagePickerControllerSourceType) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.allowsEditing = false
        picker.sourceType = type
        
        return picker
    }
    
    func encodeMessage(messageToEncode: String, inImage userImage: UIImage) {
        //After the user hit confirm
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        //Dispatching the task after  small amount of time as per MBProgressHUD's recommendation
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.01 * Double(NSEC_PER_SEC)))
        dispatch_after(popTime, dispatch_get_main_queue(), {() -> Void in
            
            let coder = UIImageCoder()
            
            //Hide the HUD
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            
            do {
                let encodedImage = try coder.encodeMessage(messageToEncode, inImage: userImage, encryptedWithPassword: PictographDataController.sharedController.getUserEncryptionKeyIfEnabled())
                //Show the share sheet if the image exists
                self.showShareSheetWithImage(encodedImage)
                
            } catch let error as NSError {
                
                //Catch the error
                self.showMessageInAlertController("Error", message: error.localizedDescription)
            }
        })
    }
    
    //Decoding a message that is hidden in an image
    func decodeMessageInImage(userImage: UIImage) {
        
        //No need to show HUD because this doesn't take long
        
        let coder = UIImageCoder()
        
        //Provide no password if encryption/decryption is off
        let providedPassword = mainEncodeView.encryptionSwitch.on ? mainEncodeView.encryptionKeyField.text : ""
        
        do {
            let decodedMessage = try coder.decodeMessageInImage(userImage, encryptedWithPassword: providedPassword)
            //Show the message if it was successfully decoded
            showMessageInAlertController("Hidden Message", message: decodedMessage)
            
        } catch let error as NSError {
            
            //Catch the error
            showMessageInAlertController("Error Decoding", message: error.localizedDescription)
        }
    }
    
    //Building the alert that gets the message that the user wants to encode
    func buildGetMessageController(title: String, message: String?, isSecure: Bool, withPlaceHolder placeHolder:String) -> PMKAlertController {
        
        let getMessageController = PMKAlertController(title: title, message: message, preferredStyle: .Alert)
        let confirmAction = getMessageController.addActionWithTitle("Confirm") //Saving the confirmAction so it can be enabled/disabled
        getMessageController.addActionWithTitle("Cancel", style: .Cancel)
        
        //Building the text field with the correct settings
        getMessageController.addTextFieldWithConfigurationHandler({(textField: UITextField) -> Void in
            textField.placeholder = placeHolder
            textField.secureTextEntry = isSecure
            confirmAction.enabled = false
            
            //Confirm is only enabled if there is text
            NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue(), usingBlock: {(notification: NSNotification) -> Void in
                //Enabled when the text isn't blank
                confirmAction.enabled = (textField.text != "")
            })
            
        })
        
        return getMessageController
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
    func showMessageInAlertController(title:String, message: String) {
        let showMessageController = PMKAlertController(title: title, message: message, preferredStyle: .Alert)
        showMessageController.addActionWithTitle("Dismiss", style: .Default)
        
        promiseViewController(showMessageController)
    }
    
    //MARK: - Methods for when the settings change
    
    func showPasswordOnScreenChanged() {
        //Set the opposite of what it currently is
        mainEncodeView.encryptionKeyField.secureTextEntry = !mainEncodeView.encryptionKeyField.secureTextEntry
    }
}
