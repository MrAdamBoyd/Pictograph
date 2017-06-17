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
import AVFoundation
import Photos
import StoreKit

//For image encoding
//TODO: Fingerprint reader for password

class PictographMainViewController: PictographViewController, UINavigationControllerDelegate, UITextFieldDelegate, UIScrollViewDelegate, EAIntroDelegate, CreatesNavigationTitle {
    
    //UI elements
    private let mainEncodeView = MainEncodingView()
    private var settingsNavVC: UINavigationController? //Stored to animate nightMode
    private var imagePickerDidPickImage: ((UIImage) -> Void)?
    var currentImage: UIImage? {
        didSet {
            self.mainEncodeView.imageView.image = self.currentImage
            self.enableOrDisableButtons()
        }
    }
    private var dragDropManager: DragDropManager?
    private weak var hiddenImageView: HiddenImageView?
    private var hiddenImageWindow: UIWindow?
    
    /// Checks to make sure the password settings are correct. Makes sure either encryption is disabled or encryption is enabled and the password isn't empty
    private var passwordSettingsValid: Bool {
        return (!PictographDataController.shared.userEncryptionPassword.isEmpty && PictographDataController.shared.userEncryptionIsEnabled) || !PictographDataController.shared.userEncryptionIsEnabled
    }
    
    //MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Pictograph"
        self.navigationItem.titleView = self.createNavigationTitle("Pictograph")
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(self.openSettings))
        
        //Adding all the UI elements to the screen
        self.mainEncodeView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 64)
        self.mainEncodeView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(mainEncodeView)
        
        //0px from bottom of topBar, 0px from left, right, bottom
        self.mainEncodeView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.mainEncodeView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.mainEncodeView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.mainEncodeView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        //Setting up the actions for the elements
        self.mainEncodeView.encodeMessageButton.addTarget(self, action: #selector(self.startEncodeMessageProcess), for: .touchUpInside)
        self.mainEncodeView.encodeImageButton.addTarget(self, action: #selector(self.startEncodeImageProcess), for: .touchUpInside)
        self.mainEncodeView.decodeButton.addTarget(self, action: #selector(self.startDecodeProcess), for: .touchUpInside)
        self.mainEncodeView.encryptionKeyField.delegate = self
        self.mainEncodeView.encryptionSwitch.addTarget(self, action: #selector(self.switchToggled(_:)), for: .valueChanged)
        self.mainEncodeView.delegate = self
        
        if self.setUpAndShowIntroViews() {
            //If intro views are shown, hide UI elements
            self.mainEncodeView.alpha = 0
            self.navigationController?.setNavigationBarHidden(true, animated: false)
        }
        
        //Add gesture recognizer to image view
        self.mainEncodeView.imageView.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.presentImageSelectActionSheet))
        tapGestureRecognizer.numberOfTapsRequired = 1
        self.mainEncodeView.imageView.addGestureRecognizer(tapGestureRecognizer)
        
        //Share button
        self.mainEncodeView.shareButton.addTarget(self, action: #selector(self.showShareSheetWithCurrentImage), for: .touchUpInside)
        
        //Drag and drop
        if #available(iOS 11, *) {
            self.dragDropManager = DragDropManager(imageView: self.mainEncodeView.imageView, in: self.view)
            let dragInteraction = UIDragInteraction(delegate: self.dragDropManager!)
            self.mainEncodeView.imageView.addInteraction(dragInteraction)
            
            let dropInteraction = UIDropInteraction(delegate: self.dragDropManager!)
            self.mainEncodeView.imageView.addInteraction(dropInteraction)
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
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.mainEncodeView.encryptionKeyField.isFirstResponder {
            self.endEditingAndSetPassword()
        }
    }
    
    @objc func openSettings() {
        //Setting the title, button title, and action
        let settings = SettingsViewController.createWithNavigationController()
        self.settingsNavVC = settings
        
        if UIDevice.current.userInterfaceIdiom == .pad {
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
    
    //Enable or disables all buttons within the app depending on app settings
    private func enableOrDisableButtons() {
        let imageExists = self.currentImage != nil
        self.mainEncodeView.largeTapSelectImageLabel.isHidden = imageExists
        self.mainEncodeView.smallTapSelectImageLabel.isHidden = !imageExists
        
        self.mainEncodeView.encodeMessageButton.isEnabled = imageExists
        self.mainEncodeView.encodeMessageButton.alpha = imageExists ? 1 : 0.5
        
        let encryptionEnabled = PictographDataController.shared.userEncryptionIsEnabled
        self.mainEncodeView.encodeImageButton.isEnabled = imageExists && !encryptionEnabled
        self.mainEncodeView.encodeImageButton.alpha = !encryptionEnabled && imageExists ? 1 : 0.5
        
        self.mainEncodeView.decodeButton.isEnabled = imageExists
        self.mainEncodeView.decodeButton.alpha = imageExists ? 1 : 0.5
        
        self.mainEncodeView.shareButton.isEnabled = imageExists
        self.mainEncodeView.shareButton.imageView?.alpha = imageExists ? 1 : 0.5
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
    @objc func pasteFromClipboard() {
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
        PictographDataController.shared.userEncryptionPassword = self.mainEncodeView.encryptionKeyField.text ?? ""
        
        if PictographDataController.shared.userEncryptionPassword.isEmpty {
            self.setEncryptionEnabled(false)
            self.mainEncodeView.encryptionSwitch.setOn(false, animated: true)
        }
    }
    
    //MARK: - UITextFieldDelegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.endEditingAndSetPassword()
    }
    
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
    
    /// Shows the intro views for the app that explain what the app does
    ///
    /// - Returns: true if intro views shown, false otherwise
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
    
    @objc func switchToggled(_ sender: AnyObject) {
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
        self.enableOrDisableButtons()
    }
    
    //Starting the encode process
    @objc func startEncodeMessageProcess() {
        self.endEditingAndSetPassword()
        
        if self.passwordSettingsValid {
            
            self.showGetMessageController("Enter your message", withPlaceHolder: "Your message here")
            
        } else {
            //Show message: encryption is enabled and the key is blank
            showMessageInAlertController("No Encryption Key", message: "Encryption is enabled but your password is blank, please enter a password.", includeCopyButton: false)
        }
    }
    
    //Starting the process for the user to encode an image within another image
    @objc func startEncodeImageProcess() {
        self.endEditingAndSetPassword()
        
        self.determineHowToPresentImagePicker() { [weak self] image in
            self?.encodeImage(image)
        }
    }
    
    //Starting the decoding process
    @objc func startDecodeProcess() {
        self.endEditingAndSetPassword()
        
        if self.passwordSettingsValid {
            
            self.decodeMessage()
            
        } else {
            //Show message: encryption is enabled and the key is blank
            showMessageInAlertController("No Encryption Key", message: "Encryption is enabled but your password is blank, please enter a password.", includeCopyButton: false)
        }
    }
    
    //Showing the action sheet
    
    @objc func presentImageSelectActionSheet() {
        self.determineHowToPresentImagePicker() { [weak self] image in
            DispatchQueue.main.async {
                self?.currentImage = image
            }
        }
    }
    
    /// Determines how to show the image picker. If the device has the camera, shows a picker that lets the user determine if they want to use the camera or just pick from the library.
    ///
    /// - parameter onImagePick: called with the image when the image is selected by the user
    func determineHowToPresentImagePicker(onImagePick: @escaping (UIImage) -> Void) {
        
        self.imagePickerDidPickImage = onImagePick
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            //Device has camera & library, show option to choose
           
            //If the device is an iPad, popup in the middle of screen
            let alertStyle: UIAlertControllerStyle = (UIDevice.current.userInterfaceIdiom == .pad) ? .alert : .actionSheet
            
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
            let mediaType: AVMediaType = .video //This is the type for the camera
            
            switch AVCaptureDevice.authorizationStatus(for: mediaType) {
            case .authorized: self.createAndPresentPicker(withType: type)
            case .notDetermined, .denied, .restricted:
                // Prompting user for the permission to use the camera.
                AVCaptureDevice.requestAccess(for: mediaType) { granted in
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
    
    /// Encodes an image with the currently selected image
    ///
    /// - Parameter messageToEncode: message that should be encoded
    func encodeMessage(_ messageToEncode: String) {
        guard let image = self.currentImage else { return }
        
        //After the user hit confirm
        SVProgressHUD.show()
        
        //Dispatching the task after  small amount of time as per SVProgressHUD's recommendation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            let coder = PictographImageCoder()
            
            //Hide the HUD
            SVProgressHUD.dismiss()
            
            do {
                let providedPassword = self.mainEncodeView.encryptionSwitch.isOn ? self.mainEncodeView.encryptionKeyField.text ?? "" : ""
                
                let encodedImage = try coder.encode(message: messageToEncode, in: image, encryptedWithPassword: providedPassword)
                self.currentImage = UIImage(data: encodedImage)
                //Show the share sheet if the image exists
                self.showShareSheet(with: encodedImage)
                
            } catch let error {

                //Catch the error
                self.showMessageInAlertController("Error", message: error.localizedDescription, includeCopyButton: false)
            }
        }
    }
    
    func encodeImage(_ imageToHide: UIImage) {
        guard let image = self.currentImage else { return }
        
        //After the user hit confirm
        SVProgressHUD.show(withStatus: "This might take a while...")
        
        //Dispatching the task after  small amount of time as per SVProgressHUD's recommendation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            let coder = PictographImageCoder()
            
            //Hide the HUD
            SVProgressHUD.dismiss()
            
            do {
                
                let encodedImage = try coder.encode(image: imageToHide, in: image)
                self.currentImage = UIImage(data: encodedImage)
                //Show the share sheet if the image exists
                self.showShareSheet(with: encodedImage)
                
            } catch let error {
                
                //Catch the error
                self.showMessageInAlertController("Error", message: error.localizedDescription, includeCopyButton: false)
            }
        }
    }
    
    /// Decoding a message that is hidden in an image
    func decodeMessage() {
        guard let image = self.currentImage else { return }
        
        //No need to show HUD because this doesn't take long
        let coder = PictographImageCoder()
        
        //Provide no password if encryption/decryption is off
        let providedPassword = mainEncodeView.encryptionSwitch.isOn ? mainEncodeView.encryptionKeyField.text ?? "" : ""
        
        var hiddenString: NSString?
        var hiddenImage: UIImage?
        var error: NSError?
        coder.decode(image, encryptedWithPassword: providedPassword, hiddenStringPointer: &hiddenString, hiddenImagePointer: &hiddenImage, error: &error)
        
        guard error == nil else {
            self.showMessageInAlertController("Error Decoding", message: error!.localizedDescription, includeCopyButton: false)
            return
        }
        
        if let decodedMessage = hiddenString {
            //Show the message if it was successfully decoded
            self.showMessageInAlertController("Hidden Message", message: decodedMessage as String, includeCopyButton: true) { _ in
                
                //After alert controller is dismissed, prompt the user for ratings if they haven't been already for this version
                if #available(iOS 10.3, *), !PictographDataController.shared.hasUserBeenPromptedForRatings {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        SKStoreReviewController.requestReview()
                        PictographDataController.shared.setHasUserBeenPromptedForRatings()
                    }
                }
                
            }
        } else if let decodedImage = hiddenImage {
            
            //Present a custom sheet for the image
            let createdWindow = HiddenImageView.createInWindow(from: self, showing: decodedImage)
            self.hiddenImageView = createdWindow.view
            self.hiddenImageWindow = createdWindow.window
        }
        
    }
    
    /// Builds the UIAlertController that will get the message to encode from the user
    ///
    /// - Parameters:
    ///   - title: title of the UIAlertController
    ///   - placeHolder: placeholder to have in the textbox
    func showGetMessageController(_ title: String, withPlaceHolder placeHolder: String) {
        
        let getMessageController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        
        //Saving the confirmAction so it can be enabled/disabled
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { _ in
            self.encodeMessage(getMessageController.textFields!.first!.text!)
        }
        getMessageController.addAction(confirmAction)
        
        //Set current action to none
        getMessageController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        //Building the text field with the correct settings
        getMessageController.addTextField(configurationHandler: { textField in
            textField.placeholder = placeHolder
            confirmAction.isEnabled = false
            textField.inputAccessoryView = self.buildAccessoryButton()
            
            //Confirm is only enabled if there is text
            NotificationCenter.default.addObserver(forName: Notification.Name.UITextFieldTextDidChange, object: textField, queue: OperationQueue.main) { notification -> Void in
                //Enabled when the text isn't blank
                confirmAction.isEnabled = (textField.text != "")
            }
        })
        
        self.present(getMessageController, animated: true, completion: nil)
    }
    
    /// Shows the share sheet with the image that's currently being stored
    @objc private func showShareSheetWithCurrentImage() {
        guard let image = self.currentImage, let data = UIImagePNGRepresentation(image) else { return }
        self.showShareSheet(with: data)
    }
    
    /// Shows the share sheet with the image data
    ///
    /// - Parameter imageData: png representation of the image
    func showShareSheet(with imageData: Data) {
        let activityController = UIActivityViewController(activityItems: [imageData], applicationActivities: nil)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            //On an iPad, show the popover from the button
            activityController.modalPresentationStyle = .popover
            activityController.popoverPresentationController!.sourceView = self.mainEncodeView.imageView
            //Presenting it from the middle of the encode button
            activityController.popoverPresentationController!.sourceRect = CGRect(x: self.mainEncodeView.imageView.frame.width / 2, y: self.mainEncodeView.imageView.frame.height / 2, width: 0, height: 0)
        }
        
        //Showing the share sheet
        present(activityController, animated: true, completion: nil)
    }
    
    //Shows the decoded message in an alert controller
    func showMessageInAlertController(_ title: String, message: String, includeCopyButton: Bool, onDismiss completion: ((UIAlertAction) -> Void)? = nil) {
        let showMessageController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        _ = showMessageController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: completion))
        
        if includeCopyButton {
            //Let the user copy the text
            _ = showMessageController.addAction(UIAlertAction(title: "Copy Text", style: .default, handler: { _ in
                let pasteboard = UIPasteboard.general
                pasteboard.string = message
            }))
        }
        
        self.present(showMessageController, animated: true, completion: nil)
    }
    
    //MARK: - Methods for when the settings change
    
    @objc func showPasswordOnScreenChanged() {
        //Set the opposite of what it currently is
        mainEncodeView.encryptionKeyField.isSecureTextEntry = !mainEncodeView.encryptionKeyField.isSecureTextEntry
    }
    
    //Animates night mode changing when on an iPad
    @objc func changeNightModeAnimated() {
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
        
        for button in [self.mainEncodeView.encodeMessageButton, self.mainEncodeView.encodeImageButton, self.mainEncodeView.decodeButton] {
            
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

extension PictographMainViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        self.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            self.showMessageInAlertController("Error", message: "Couldn't get image", includeCopyButton: false)
            return
        }
        
        self.imagePickerDidPickImage?(image)
        self.imagePickerDidPickImage = nil
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension PictographMainViewController: HiddenImageViewDelegate {
    
    //Let the user share the image from the share sheet
    func showShareSheetFromHiddenImageView() {
        self.closeHiddenImageView() {
            guard let image = self.currentImage, let data = UIImagePNGRepresentation(image) else {
                return
            }
            
            self.showShareSheet(with: data)
        }
    }
    
    //Close the view
    func closeHiddenImageView(_ completion: (() -> Void)?) {
        DispatchQueue.main.async {
            self.hiddenImageView?.animateCenterPopup(visible: false) {
                UIView.animate(withDuration: 0.5, animations: { [unowned self] in
                    self.hiddenImageWindow?.alpha = 0
                    }, completion: { _ in
                        self.hiddenImageView = nil
                        self.hiddenImageWindow = nil
                        completion?()
                })
            }
        }
    }
}
