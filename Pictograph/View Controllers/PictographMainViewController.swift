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
import SVProgressHUD
import PromiseKit
import CustomIOSAlertView

//What we are currently doing
enum PictographAction: Int {
    case encodingMessage = 0, decodingMessage
}

class PictographMainViewController: PictographViewController, UINavigationControllerDelegate, UITextFieldDelegate, EAIntroDelegate, CreatesNavigationTitle {
    
    //UI elements
    let mainEncodeView = MainEncodingView()
    var settingsNavVC: UINavigationController! //Stored to animate nightMode
    
    //MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Pictograph"
        self.navigationItem.titleView = self.createNavigationTitle("Pictograph")
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(self.openSettings))
        
        //Adding all the UI elements to the screen
        self.mainEncodeView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(mainEncodeView)
        
        //0px from bottom of topBar, 0px from left, right, bottom
        self.mainEncodeView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.mainEncodeView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.mainEncodeView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.mainEncodeView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        //Setting up the actions for the elements
        self.mainEncodeView.encodeButton.addTarget(self, action: #selector(self.startEncodeProcess), for: .touchUpInside)
        self.mainEncodeView.decodeButton.addTarget(self, action: #selector(self.startDecodeProcess), for: .touchUpInside)
        self.mainEncodeView.encryptionKeyField.delegate = self
        self.mainEncodeView.encryptionSwitch.addTarget(self, action: #selector(self.switchToggled(_:)), for: .valueChanged)
        
        
        if (setUpAndShowIntroViews()) {
            //If intro views are shown, hide UI elements
            self.mainEncodeView.alpha = 0
            self.navigationController?.setNavigationBarHidden(true, animated: false)
        }
        
        //Setting up the notifications for the settings
        NotificationCenter.default.addObserver(self, selector: #selector(self.showPasswordOnScreenChanged), name: NSNotification.Name(rawValue: pictographShowPasswordOnScreenSettingChangedNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.changeNightModeAnimated), name: NSNotification.Name(rawValue: pictographNightModeSettingChangedNotification), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.changeNightMode()
        self.mainEncodeView.contentSize.width = UIScreen.main.bounds.width
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        //Adjusting the content size of the scroll view when the device rotates
        self.mainEncodeView.elementContainer.frame = CGRect(x: 0, y: 0, width: size.width, height: max(size.height-44, 320))
        self.mainEncodeView.contentSize = CGSize(width: size.width, height: max(size.height-64, 320))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        
        //Saving the text
        PictographDataController.sharedController.setUserEncryptionKey(mainEncodeView.encryptionKeyField.text!)
    }
    
    func openSettings() {
        //Setting the title, button title, and action
        let settings = SettingsViewController.createWithNavigationController()
        self.settingsNavVC = settings
        
        if  UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            //On an iPad, show the popover from the button
            settings.modalPresentationStyle = .popover
            settings.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
            settings.popoverPresentationController?.backgroundColor = PictographDataController.sharedController.getUserNightModeEnabled() ? mainAppColorNight : mainAppColor
        }
        
        self.present(settings, animated: true, completion: nil)
    }
    
    //For NSNotificationCenter
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        //Saving the text
        PictographDataController.sharedController.setUserEncryptionKey(textField.text!)
        return false
    }
    
    
    //MARK: - EAIntroDelegate
    func introDidFinish(_ introView: EAIntroView!) {
        PictographDataController.sharedController.setUserFirstTimeOpeningApp(false)
        
        //Animating the views in
        UIView.animate(withDuration: 1.0, animations: { () -> Void in
            self.mainEncodeView.alpha = 1
        })
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    //MARK: - Custom methods
    
    //Shows the intro views if the user hasn't opened the app and/or if we don't have authorization to use gps
    func setUpAndShowIntroViews() -> Bool {
        let introViewArray = IntroView.buildIntroViews()
        
        if introViewArray.count > 0 {
            //If there are intro views to show
            let frameRect = CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y, width: self.view.frame.size.width, height: self.view.frame.size.height + 10) //Status bar
            let introView = EAIntroView(frame: frameRect)
            introView.pages = introViewArray
            introView.delegate = self
            introView.show(in: self.view, animateDuration: 0)
            
            //Intro view was shown, return true
            return true
        }
        
        //Intro view wasn't shown, return false
        
        return false
    }
    
    func switchToggled(_ sender: AnyObject) {
        let mySwitch = sender as! UISwitch
        let enabledOrDisabled = mySwitch.isOn
        
        //Disabling or enabling the textfield based on whether encryption is enabled
        mainEncodeView.encryptionKeyField.isEnabled = enabledOrDisabled
        
        //Animiating the alpha of the textfield
        UIView.animate(withDuration: 0.25, animations: {() -> Void in
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
                
            }.then { [unowned self] image in
                
                //Getting the message from the user
                return self.promise(getMessageController)
            
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
            _ = getPhotoForEncodingOrDecoding(false).then { image in
                //Start encoding or decoding when the image has been picked
                self.decodeMessageInImage(image)
            }
        } else {
            //Show message: encryption is enabled and the key is blank
            showMessageInAlertController("No Encryption Key", message: "Encryption is enabled but your password is blank, please enter a password.")
        }
    }
    
    //Showing the action sheet
    func getPhotoForEncodingOrDecoding(_ showCamera: Bool, showMessageInHUD message: String? = nil) -> Promise<UIImage> {
        
        if message != nil && message != nil {
            SVProgressHUD.showInfo(withStatus: message!)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) && showCamera {
            //Device has camera & library, show option to choose
           
            //If the device is an iPad, popup in the middle of screen
            let alertStyle:UIAlertControllerStyle = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad) ? .alert : .actionSheet
            
            //Building the picker to choose the type of input
            let imagePopup = PMKAlertController(title: "Select Picture", message: nil, preferredStyle: alertStyle)
            _ = imagePopup.addActionWithTitle(title: "Select from Library")
            let takePhotoPickerAction = imagePopup.addActionWithTitle(title: "Take Photo") //Saving the take photo action so we can show the proper picker later
            _ = imagePopup.addActionWithTitle(title: "Cancel", style: .cancel)

            return promise(imagePopup).then { [unowned self] action in
                var pickerType = UIImagePickerControllerSourceType.photoLibrary

                if action == takePhotoPickerAction {
                    //If the user chose to use the camera
                    pickerType = .camera
                }

                let picker = self.buildImagePickerWithSourceType(pickerType)

                return self.promise(picker)
            }
        
        } else {
            //Device has no camera, just show library
            let picker = buildImagePickerWithSourceType(.photoLibrary)
            
            return promise(picker)
        }
    }
    
    //Builds a UIImagePickerController with source type
    func buildImagePickerWithSourceType(_ type: UIImagePickerControllerSourceType) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.allowsEditing = false
        picker.sourceType = type
        
        return picker
    }
    
    func encodeMessage(_ messageToEncode: String, inImage userImage: UIImage) {
        //After the user hit confirm
        SVProgressHUD.show()
        
        //Dispatching the task after  small amount of time as per MBProgressHUD's recommendation
        let popTime = DispatchTime.now() + Double(Int64(0.01 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: popTime, execute: {() -> Void in
            
            let coder = UIImageCoder()
            
            //Hide the HUD
            SVProgressHUD.dismiss()
            
            do {
                let encodedImage = try coder.encodeMessage(messageToEncode, in: userImage, encryptedWithPassword: PictographDataController.sharedController.getUserEncryptionKeyIfEnabled())
                //Show the share sheet if the image exists
                self.showShareSheetWithImage(encodedImage)
                
            } catch let error as NSError {
                
                //Catch the error
                self.showMessageInAlertController("Error", message: error.localizedDescription)
            }
        })
    }
    
    //Decoding a message that is hidden in an image
    func decodeMessageInImage(_ userImage: UIImage) {
        
        //No need to show HUD because this doesn't take long
        
        let coder = UIImageCoder()
        
        //Provide no password if encryption/decryption is off
        let providedPassword = mainEncodeView.encryptionSwitch.isOn ? mainEncodeView.encryptionKeyField.text : ""
        
        do {
            let decodedMessage = try coder.decodeMessage(in: userImage, encryptedWithPassword: providedPassword)
            //Show the message if it was successfully decoded
            showMessageInAlertController("Hidden Message", message: decodedMessage)
            
        } catch let error as NSError {
            
            //Catch the error
            showMessageInAlertController("Error Decoding", message: error.localizedDescription)
        }
    }
    
    //Building the alert that gets the message that the user wants to encode
    func buildGetMessageController(_ title: String, message: String?, isSecure: Bool, withPlaceHolder placeHolder:String) -> PMKAlertController {
        
        let getMessageController = PMKAlertController(title: title, message: message, preferredStyle: .alert)
        let confirmAction = getMessageController.addActionWithTitle(title: "Confirm") //Saving the confirmAction so it can be enabled/disabled
        _ = getMessageController.addActionWithTitle(title: "Cancel", style: .cancel)
        
        //Building the text field with the correct settings
        getMessageController.addTextFieldWithConfigurationHandler() { textField -> Void in
            textField.placeholder = placeHolder
            textField.isSecureTextEntry = isSecure
            confirmAction.isEnabled = false
            
            //Confirm is only enabled if there is text
            NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: textField, queue: OperationQueue.main) { notification -> Void in
                //Enabled when the text isn't blank
                confirmAction.isEnabled = (textField.text != "")
            }
            
        }
        
        return getMessageController
    }
    
    //Shows the share sheet with the UIImage in PNG form
    func showShareSheetWithImage(_ image: Data) {
        let activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        
        if  UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            //On an iPad, show the popover from the button
            activityController.modalPresentationStyle = .popover
            activityController.popoverPresentationController!.sourceView = mainEncodeView.encodeButton
            //Presenting it from the middle of the encode button
            activityController.popoverPresentationController!.sourceRect = CGRect(x: mainEncodeView.encodeButton.frame.width / 2, y: mainEncodeView.encodeButton.frame.height / 2, width: 0, height: 0)
        }
        
        //Showing the share sheet
        present(activityController, animated: true, completion: nil)
    }
    
    //Shows the decoded message in an alert controller
    func showMessageInAlertController(_ title:String, message: String) {
        let showMessageController = PMKAlertController(title: title, message: message, preferredStyle: .alert)
        _ = showMessageController.addActionWithTitle(title: "Dismiss", style: .default)
        
        _ = promise(showMessageController)
    }
    
    //Shows an image in an alert controller, allows user to dismiss and save
    func showImageInAlertController(_ title: String, image: Data) {

        //Creating the custom alert view
        let alertView = CustomIOSAlertView()
        
        //Adding the image to the container view
        let imageView = UIImageView(image: UIImage(data: image))
        imageView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width - 20, height: UIScreen.main.bounds.size.width - 20)
        imageView.contentMode = .scaleAspectFit
        alertView?.containerView = imageView
        
        alertView?.buttonTitles = ["Dismiss", "Save"]
        
        alertView?.onButtonTouchUpInside = ({ (alertView, buttonIndex) -> Void in
            //If the button index is 1 (save button), show the share sheet
            if buttonIndex == 1 {
                alertView?.close()
                self.showShareSheetWithImage(image)
            }
        })

        
        alertView?.show()
    }
    
    //MARK: - Methods for when the settings change
    
    func showPasswordOnScreenChanged() {
        //Set the opposite of what it currently is
        mainEncodeView.encryptionKeyField.isSecureTextEntry = !mainEncodeView.encryptionKeyField.isSecureTextEntry
    }
    
    //Animates night mode changing when on an iPad
    func changeNightModeAnimated() {
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.changeNightMode()
            self.settingsNavVC.popoverPresentationController?.backgroundColor = PictographDataController.sharedController.getUserNightModeEnabled() ? mainAppColorNight : mainAppColor
        }) 
    }
    
    //Changes the look of all the UI elements that need to change when night mode is activated
    func changeNightMode() {
        self.view.backgroundColor = PictographDataController.sharedController.getUserNightModeEnabled() ? mainAppColorNight : mainAppColor
        self.navigationController?.navigationBar.barTintColor = PictographDataController.sharedController.getUserNightModeEnabled() ? mainAppColorNight : mainAppColor
        
        let nightMode = PictographDataController.sharedController.getUserNightModeEnabled()
        
        //Setting the color of the keyboard
        self.mainEncodeView.encryptionKeyField.keyboardAppearance = nightMode ? .dark : .default
        
        for button in [self.mainEncodeView.encodeButton, self.mainEncodeView.decodeButton] {
            
            //Button background
            button.backgroundColor = nightMode ? mainAppColorNight : UIColor.white
            
            button.highlightColor = nightMode ? mainAppColorNight : UIColor.white
            
            //Text color
            button.setTitleColor(nightMode ? UIColor.white : mainAppColor, for: .normal)
            button.setTitleColor(nightMode ? UIColor.white.withAlphaComponent(0.5) : mainAppColorHighlighted, for: .highlighted)
            
            if nightMode {
                //Add a border
                button.layer.borderColor = UIColor.white.cgColor
                button.layer.borderWidth = 1
            } else {
                button.layer.borderWidth = 0
            }
        }
    }
}
