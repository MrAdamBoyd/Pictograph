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
    
    func getUserFirstTimeOpeningApp() -> Bool {
        return user.firstTimeOpeningApp
    }
    
    func setUserFirstTimeOpeningApp(_ firstTime: Bool) {
        user.firstTimeOpeningApp = firstTime
        saveCurrentUser()
    }
    
    func getUserEncryptionEnabled() -> Bool {
        return user.encryptionEnabled;
    }
    
    func setUserEncryptionEnabled(_ enabledOrNot: Bool) {
        user.encryptionEnabled = enabledOrNot
        saveCurrentUser()
    }
    
    func getUserEncryptionKey() -> String? {
        let password = user.encryptionPassword
        if password == "" {
            return nil
        }
        
        return password
    }
    
    //Gets the user encryption key as a String
    func getUserEncryptionKeyString() -> String {
        return user.encryptionPassword
    }
    
    func getUserEncryptionKeyIfEnabled() -> String? {
        if user.encryptionEnabled {
            return self.getUserEncryptionKey()
        }
        
        return nil
    }
    
    func setUserEncryptionKey(_ newKey: String) {
        user.encryptionPassword = newKey
        saveCurrentUser()
    }
    
    func getUserShowPasswordOnScreen() -> Bool {
        return user.showPasswordOnScreen
    }
    
    func setUserShowPasswordOnScreen(_ enabledOrNot: Bool) {
        user.showPasswordOnScreen = enabledOrNot
        saveCurrentUser()
    }
    
    func getUserNightModeEnabled() -> Bool {
        return user.nightModeEnabled
    }
    
    func setUserDarkModeEnabled(_ enabledOrNot: Bool) {
        user.nightModeEnabled = enabledOrNot
        saveCurrentUser()
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
