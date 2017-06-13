//
//  PictographDataController.swift
//  Pictograph
//
//  Created by Adam Boyd on 2015-10-25.
//  Copyright © 2015 Adam Boyd. All rights reserved.
//

import Foundation

#if os(macOS)
import Cocoa
#else
import Crashlytics
import Fabric
#endif

private let currentUserKey = "kCurrentUserKey"

class PictographDataController: NSObject {
    
    @objc static let shared = PictographDataController()
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
    
    
    /// User's encryption password
    /// GET:
    ///     if encryption is enabled and password isn't "", returns the password
    /// SET:
    ///     if newValue is nil, sets the password as "", else, sets the password normally
    var userEncryptionPassword: String {
        get {
            return self.user.encryptionPassword
        }
        set {
            print("Setting encryption password: \(newValue)")
            self.user.encryptionPassword = newValue
            
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
    
    var userShouldStoreImages: Bool {
        get {
            return self.user.shouldStoreImages
        }
        set {
            print("Setting should store images: \(newValue)")
            self.user.shouldStoreImages = newValue
            self.saveCurrentUser()
        }
    }
    
    //MARK: - Asking user to rate the app
    
    /// This is the userdefaults key for this version of the app. Using a different key for each version
    fileprivate var thisVersionRatingKey: String {
        var defaultsKey = "userPromptedKey"
        
        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            return defaultsKey
        }
        
        defaultsKey.append("Version\(version)")
        return defaultsKey
    }
    
    /// Returns true if should be prompted for ratings, false otherwise
    var hasUserBeenPromptedForRatings: Bool {
        return UserDefaults.standard.bool(forKey: thisVersionRatingKey)
    }
    
    func setHasUserBeenPromptedForRatings() {
        UserDefaults.standard.set(true, forKey: thisVersionRatingKey)
    }
    
    
    //MARK: - analytics methods
    
    //Record a message encrypted event
    @objc func analyticsEncodeSend(_ encrypted: Bool) {
        let encryptedOrNot = encrypted ? "Encrypted" : "Unencrypted"
    
        #if os(iOS)
            Answers.logCustomEvent(withName: "Encode Message", customAttributes: ["Encryption" : encryptedOrNot])
        #endif
    }
    
    //Record a message decrypted event
    @objc func analyticsDecodeSend(_ encrypted: Bool) {
        let encryptedOrNot = encrypted ? "Encrypted" : "Unencrypted"
    
        #if os(iOS)
            Answers.logCustomEvent(withName: "Decode Message", customAttributes: ["Encryption" : encryptedOrNot])
        #endif
    }
    
    //MARK: - Other methods
    
    //Opens the website in Safari
    func goToWebsite() {
        let url = URL(string: "http://adamjboyd.com")!
        #if os(iOS)
            UIApplication.shared.openURL(url)
        #else
            NSWorkspace.shared().open(url)
        #endif
    }
    
}
