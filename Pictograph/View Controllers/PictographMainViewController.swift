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
import CustomIOSAlertView
import AVFoundation
import Photos

//What we are currently doing
enum PictographAction {
    case encoding, decoding, none
}

class PictographMainViewController: PictographViewController, UINavigationControllerDelegate, UITextFieldDelegate, UIScrollViewDelegate, EAIntroDelegate, CreatesNavigationTitle, UIImagePickerControllerDelegate {
    
    //UI elements
    let mainEncodeView = MainEncodingView()
    var settingsNavVC: UINavigationController? //Stored to animate nightMode
    var currentAction: PictographAction = .none
    var currentImage: UIImage? {
        didSet {
            self.mainEncodeView.imageView.image = self.currentImage
            
            if let _ = self.currentImage {
                self.mainEncodeView.largeTapSelectImageLabel.isHidden = true
                self.mainEncodeView.smallTapSelectImageLabel.isHidden = false
            }
        }
    }
    
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
        self.mainEncodeView.delegate = self
        
        if (setUpAndShowIntroViews()) {
            //If intro views are shown, hide UI elements
            self.mainEncodeView.alpha = 0
            self.navigationController?.setNavigationBarHidden(true, animated: false)
        }
        
        //Add gesture recognizer to image view
        self.mainEncodeView.imageView.isUserInteractionEnabled = true
//        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector())
//        self.mainEncodeView.imageView.addGestureRecognizer(<#T##gestureRecognizer: UIGestureRecognizer##UIGestureRecognizer#>)
        
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
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.endEditingAndSetPassword()
    }
    
    func openSettings() {
        //Setting the title, button title, and action
        let settings = SettingsViewController.createWithNavigationController()
        self.settingsNavVC = settings
        
        if  UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            //On an iPad, show the popover from the button
            settings.modalPresentationStyle = .popover
            settings.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
            settings.popoverPresentationController?.backgroundColor = PictographDataController.shared.userNightModeIsEnabled ? mainAppColorNight : mainAppColor
        }
        
        self.present(settings, animated: true, completion: nil)
    }
    
    //For NSNotificationCenter
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Paste from clipboard button
    
    /**
     Builds the button that is the input accessory view that is above the keyboard
     
     - returns:  button for accessory keyboard view
     */
    func buildAccessoryButton() -> UIView {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40))
        button.setTitle("Paste from clipboard", for: UIControlState())
        button.backgroundColor = UIColor(colorLiteralRed: 150/256, green: 150/256, blue: 150/256, alpha: 1)
        button.setTitleColor(UIColor(colorLiteralRed: 75/256, green: 75/256, blue: 75/256, alpha: 1), for: .highlighted)
        button.addTarget(self, action: #selector(self.pasteFromClipboard), for: .touchUpInside)
        
        return button
    }
    
    /**
     Pastes the text from the clipboard in the showing alert vc, if it exists
     */
    func pasteFromClipboard() {
        if let alertVC = self.presentedViewController as? UIAlertController {
            let pasteString = UIPasteboard.general.string
            
            if let pasteString = pasteString, !pasteString.isEmpty {
                alertVC.textFields![0].text = pasteString
                
                //Need to manually enable the confirm button because pasting doesn't trigger the notification
                for action in alertVC.actions {
                    if action.style == .default {
                        action.isEnabled = true
                        return
                    }
                }
            }
        }
    }
    
    
    /// Ends editing and sets the user's encryption password. If password is "", turns off encryption
    func endEditingAndSetPassword() {
        self.view.endEditing(true)
        PictographDataController.shared.userEncryptionPassword = self.mainEncodeView.encryptionKeyField.text
        
        if PictographDataController.shared.userEncryptionPasswordNonNil.isEmpty {
            self.setEncryptionEnabled(false)
            self.mainEncodeView.encryptionSwitch.setOn(false, animated: true)
        }
    }
    
    //MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.endEditingAndSetPassword()
        return false
    }
    
    
    //MARK: - EAIntroDelegate
    func introWillFinish(_ introView: EAIntroView!, wasSkipped: Bool) {
        PictographDataController.shared.userFirstTimeOpeningApp = false

        //Animating the views in
        UIView.animate(withDuration: 1) {
            self.mainEncodeView.alpha = 1
        }
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    //MARK: - Custom methods
    
    //Shows the intro views if the user hasn't opened the app and/or if we don't have authorization to use gps
    func setUpAndShowIntroViews() -> Bool {
        guard PictographDataController.shared.userFirstTimeOpeningApp else {
            //Don't show intro view
            return false
        }
        
        //Set up array of intro view pages
        let introViewArray = IntroView.buildIntroViews()
        let frameRect = CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y, width: self.view.frame.size.width, height: self.view.frame.size.height + 10) //Status bar
        let introView = EAIntroView(frame: frameRect)
        introView.pages = introViewArray
        introView.delegate = self
        introView.show(in: self.view, animateDuration: 0)
    
        return true
    }
    
    func switchToggled(_ sender: AnyObject) {
        let mySwitch = sender as! UISwitch
        self.setEncryptionEnabled(mySwitch.isOn)
    }
    
    
    /// Sets the bool in the data controller and animates the textfield on or off
    ///
    /// - Parameter flag: enabled or disabled
    func setEncryptionEnabled(_ flag: Bool) {
        //Disabling or enabling the textfield based on whether encryption is enabled
        mainEncodeView.encryptionKeyField.isEnabled = flag
        
        //Animiating the alpha of the textfield
        UIView.animate(withDuration: 0.25) {
            self.mainEncodeView.encryptionKeyField.alpha = flag ? 1.0 : 0.5
        }
        
        PictographDataController.shared.userEncryptionIsEnabled = flag
    }
    
    //Starting the encode process
    func startEncodeProcess() {
        self.endEditingAndSetPassword()
        
        /* True if encrytption is enabled AND the key isn't blank
        OR encrytion is disabled
        */
        if ((!PictographDataController.shared.userEncryptionPasswordNonNil.isEmpty && PictographDataController.shared.userEncryptionIsEnabled) || !PictographDataController.shared.userEncryptionIsEnabled) {
            
            self.currentAction = .encoding
            self.determineHowToPresentImagePicker(haveCameraOption: true)
            
        } else {
            //Show message: encryption is enabled and the key is blank
            showMessageInAlertController("No Encryption Key", message: "Encryption is enabled but your password is blank, please enter a password.")
        }
    }
    
    //Starting the decoding process
    func startDecodeProcess() {
        self.endEditingAndSetPassword()
        
        /* True if encrytption is enabled AND the key isn't blank
         OR encrytion is disabled
         */
        if ((!PictographDataController.shared.userEncryptionPasswordNonNil.isEmpty && PictographDataController.shared.userEncryptionIsEnabled) || !PictographDataController.shared.userEncryptionIsEnabled) {
            
            self.currentAction = .decoding
            self.determineHowToPresentImagePicker(haveCameraOption: false)
            
        } else {
            //Show message: encryption is enabled and the key is blank
            showMessageInAlertController("No Encryption Key", message: "Encryption is enabled but your password is blank, please enter a password.")
        }
    }
    
    //Showing the action sheet
    
    
    /// Determines how to show the image picker. If the device has the camera, shows a picker that lets the user determine if they want to use the camera or just pick from the library.
    ///
    /// - Parameter showCamera: whether or not to have an option to pick the camera
    func determineHowToPresentImagePicker(haveCameraOption showCamera: Bool) {
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) && showCamera {
            //Device has camera & library, show option to choose
           
            //If the device is an iPad, popup in the middle of screen
            let alertStyle: UIAlertControllerStyle = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad) ? .alert : .actionSheet
            
            //Building the picker to choose the type of input
            let imagePopup = UIAlertController(title: "Select Picture", message: nil, preferredStyle: alertStyle)
            
            //Selecting from library
            imagePopup.addAction(UIAlertAction(title: "Select from Library", style: .default, handler: { _ in
                self.handlePermissionsForImagePicker(withType: .photoLibrary)
            }))
                
            imagePopup.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { _ in
                self.handlePermissionsForImagePicker(withType: .camera)
            }))
            
            imagePopup.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(imagePopup, animated: true, completion: nil)
        
        } else {
            //Device has no camera, just show library
            self.handlePermissionsForImagePicker(withType: .photoLibrary)
        }
    }
    
    /// Deals with the permission for both the camera and the photo library. If permission is granted, shows the picker with the provided type
    ///
    /// - Parameter type: type of photo picker to show
    func handlePermissionsForImagePicker(withType type: UIImagePickerControllerSourceType) {
        
        switch type {
        case .camera:
            
            //Getting permission from the camera
            let mediaType = AVMediaTypeVideo //This is the type for the camera
            
            switch AVCaptureDevice.authorizationStatus(forMediaType: mediaType) {
            case .authorized: self.createAndPresentPicker(withType: type)
            case .notDetermined, .denied, .restricted:
                // Prompting user for the permission to use the camera.
                AVCaptureDevice.requestAccess(forMediaType: mediaType) { granted in
                    if granted {
                        DispatchQueue.main.async {
                            self.createAndPresentPicker(withType: type)
                        }
                    } else {
                        SVProgressHUD.showError(withStatus: "Permission not granted! Go to Settings to enable permission.")
                    }
                }
            }
        default:
            
            //Getting permission for the photo library
            switch PHPhotoLibrary.authorizationStatus() {
            case .authorized:  self.createAndPresentPicker(withType: type)
            default:
                PHPhotoLibrary.requestAuthorization() { status in
                    switch status {
                    case .authorized:
                        DispatchQueue.main.async {
                            self.createAndPresentPicker(withType: type)
                        }
                    default:
                        SVProgressHUD.showError(withStatus: "Permission not granted! Go to Settings to enable permission.")
                    }
                }
                
            }
        }
    }
    
    func createAndPresentPicker(withType type: UIImagePickerControllerSourceType) {
        let picker = UIImagePickerController()
        picker.allowsEditing = false
        picker.sourceType = type
        picker.delegate = self
        
        self.present(picker, animated: true, completion: nil)
    }
    
    func encodeMessage(_ messageToEncode: String, inImage userImage: UIImage) {
        //After the user hit confirm
        SVProgressHUD.show()
        
        //Dispatching the task after  small amount of time as per MBProgressHUD's recommendation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            let coder = UIImageCoder()
            
            //Hide the HUD
            SVProgressHUD.dismiss()
            
            do {
                let encodedImage = try coder.encodeMessage(messageToEncode, in: userImage, encryptedWithPassword: PictographDataController.shared.userEncryptionPassword)
                //Show the share sheet if the image exists
                self.showShareSheetWithImage(encodedImage)

            } catch let error {

                //Catch the error
                self.showMessageInAlertController("Error", message: error.localizedDescription)
            }
        }
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
            
        } catch let error {
            
            //Catch the error
            showMessageInAlertController("Error Decoding", message: error.localizedDescription)
        }
    }
    
    /// Builds the UIAlertController that will get the message to encode from the user
    ///
    /// - Parameters:
    ///   - title: title of the UIAlertController
    ///   - placeHolder: placeholder to have in the textbox
    ///   - image: image to hide the message in
    func showGetMessageController(_ title: String, withPlaceHolder placeHolder: String, forImage image: UIImage) {
        
        let getMessageController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        
        //Saving the confirmAction so it can be enabled/disabled
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { _ in
            self.encodeMessage(getMessageController.textFields!.first!.text!, inImage: image)
        }
        getMessageController.addAction(confirmAction)
        
        //Set current action to none
        getMessageController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            self.currentAction = .none
        }))
        
        //Building the text field with the correct settings
        getMessageController.addTextField(configurationHandler: { textField in
            textField.placeholder = placeHolder
            confirmAction.isEnabled = false
            textField.inputAccessoryView = self.buildAccessoryButton()
            
            //Confirm is only enabled if there is text
            NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: textField, queue: OperationQueue.main) { notification -> Void in
                //Enabled when the text isn't blank
                confirmAction.isEnabled = (textField.text != "")
            }
        })
        
        self.present(getMessageController, animated: true, completion: nil)
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
    func showMessageInAlertController(_ title: String, message: String) {
        let showMessageController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        _ = showMessageController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        
        self.present(showMessageController, animated: true, completion: nil)
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
            self.settingsNavVC?.popoverPresentationController?.backgroundColor = PictographDataController.shared.userNightModeIsEnabled ? mainAppColorNight : mainAppColor
        }) 
    }
    
    //Changes the look of all the UI elements that need to change when night mode is activated
    func changeNightMode() {
        self.view.backgroundColor = PictographDataController.shared.userNightModeIsEnabled ? mainAppColorNight : mainAppColor
        self.navigationController?.navigationBar.barTintColor = PictographDataController.shared.userNightModeIsEnabled ? mainAppColorNight : mainAppColor
        
        let nightMode = PictographDataController.shared.userNightModeIsEnabled
        
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
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        self.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            self.showMessageInAlertController("Error", message: "Couldn't get image")
            return
        }
        
        switch self.currentAction {
        case .encoding:
            self.showGetMessageController("Enter your message", withPlaceHolder: "Your message here", forImage: image)
        case .decoding:
            self.decodeMessageInImage(image)
        default:
            break
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
        self.currentAction = .none
    }
}
