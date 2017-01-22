//
//  PictographDataController.swift
//  Pictograph
//
//  Created by Adam Boyd on 2015-10-25.
//  Copyright © 2015 Adam Boyd. All rights reserved.
//

import Foundation
import Crashlytics
import Fabric

private let currentUserKey = "kCurrentUserKey"

class PictographDataController: NSObject {
    
    static let shared = PictographDataController()
    fileprivate var user = CurrentUser()
    
    //When the singleton is first initialized
    fileprivate override init() {
        super.init()

        if let unarchivedObject = UserDefaults.standard.object(forKey: currentUserKey) as? Data {
            //If the saved object exists
            
            if let savedUser = NSKeyedUnarchiver.unarchiveObject(with: unarchivedObject) as? CurrentUser {
                //If the app could successfully unarchive it
                user = savedUser
            }
        }
        
        //Save the user
        saveCurrentUser()
    }
    
    
    //MARK: - CurrentUser methods
    
    //Saving the user and settings to disk
    func saveCurrentUser() {
        let archivedObject = NSKeyedArchiver.archivedData(withRootObject: user)
        UserDefaults.standard.set(archivedObject, forKey: currentUserKey)
    }
    
    var userFirstTimeOpeningApp: Bool {
        get {
            return self.user.firstTimeOpeningApp
        }
        set {
            print("Setting first time opening app: \(newValue)")
            self.user.firstTimeOpeningApp = newValue
            self.saveCurrentUser()
        }
    }
    
    var userEncryptionIsEnabled: Bool {
        get {
            return self.user.encryptionEnabled
        }
        set {
            print("Setting encryption enabled: \(newValue)")
            self.user.encryptionEnabled = newValue
            self.saveCurrentUser()
        }
    }
    
    /// Returns the user's encryption key. No logic
    var userEncryptionPasswordNonNil: String {
        return self.user.encryptionPassword
    }
    
    
    /// User's encryption password
    /// GET:
    ///     if encryption is enabled and password isn't "", returns the password
    /// SET:
    ///     if newValue is nil, sets the password as "", else, sets the password normally
    var userEncryptionPassword: String? {
        get {
            guard self.user.encryptionEnabled else {
                return nil
            }
            
            let password = self.user.encryptionPassword
            guard !password.isEmpty else {
                return nil
            }
            
            return password
        }
        set {
            if let newValue = newValue {
                print("Setting encryption password: \(newValue)")
                self.user.encryptionPassword = newValue
            } else {
                print("Setting encryption password: \(newValue)")
                self.user.encryptionPassword = ""
            }
            
            self.saveCurrentUser()
        }
    }
    
    var userShowPasswordOnScreen: Bool {
        get {
            return self.user.showPasswordOnScreen
        }
        set {
            print("Setting password on screen: \(newValue)")
            self.user.showPasswordOnScreen = newValue
            self.saveCurrentUser()
        }
    }
    
    var userNightModeIsEnabled: Bool {
        get {
            return self.user.nightModeEnabled
        }
        set {
            print("Setting night mode enabled: \(newValue)")
            self.user.nightModeEnabled = newValue
            self.saveCurrentUser()
        }
    }
    
    
    //MARK: - analytics methods
    
    //Record a message encrypted event
    func analyticsEncodeSend(_ encrypted:Bool) {
        let encryptedOrNot = encrypted ? "Encrypted" : "Unencrypted"
    
        Answers.logCustomEvent(withName: "Encode Message", customAttributes: ["Encryption" : encryptedOrNot])
    }
    
    //Record a message decrypted event
    func analyticsDecodeSend(_ encrypted: Bool) {
        let encryptedOrNot = encrypted ? "Encrypted" : "Unencrypted"
    
        Answers.logCustomEvent(withName: "Decode Message", customAttributes: ["Encryption" : encryptedOrNot])
    }
    
    //MARK: - Other methods
    
    //Opens the website in Safari
    func goToWebsite() {
        UIApplication.shared.openURL(URL(string: "http://adamjboyd.com")!)
    }
    
}
