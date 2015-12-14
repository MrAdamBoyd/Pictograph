//
//  CurrentUser.swift
//  Pictograph
//
//  Created by Adam Boyd on 2015-10-25.
//  Copyright © 2015 Adam Boyd. All rights reserved.
//

import Foundation

//Need to use hungarian notation with the keys because that is how it was originally, it would be possible to change it later
private let firstTimeOpeningAppKey = "kFirstTimeOpeningAppKey"
private let encryptionEnabledKey = "kEncryptionEnabledKey"
private let encryptionPasswordKey = "kEncryptionKey"
private let showPasswordOnScreenKey = "showPasswordOnScreenKey"
private let nightModeEnabledKey = "nightModeEnabledKey"

class CurrentUser: NSObject, NSCoding, NSSecureCoding {
    var firstTimeOpeningApp: Bool = true
    var encryptionEnabled: Bool = false
    var encryptionPassword : NSString = ""
    var showPasswordOnScreen: Bool = true
    var nightModeEnabled: Bool = false
    
    override init() { super.init() }
    
    //MARK: - NSCoding
    required init?(coder aDecoder: NSCoder) {
        //Variables in from start
        
        //First time opening app
        if let firstTimeOpeningAppNumber = aDecoder.decodeObjectOfClass(NSNumber.self, forKey: firstTimeOpeningAppKey) {
            firstTimeOpeningApp = firstTimeOpeningAppNumber.boolValue
        }
        
        //Encryption enabled
        if let encryptionEnabledNumber = aDecoder.decodeObjectOfClass(NSNumber.self, forKey: encryptionEnabledKey) {
            encryptionEnabled = encryptionEnabledNumber.boolValue
        }
        
        //Encryption key
        if let storedEncryptionPassword = aDecoder.decodeObjectOfClass(NSString.self, forKey: encryptionPasswordKey) {
            encryptionPassword = storedEncryptionPassword
        }
        
        
        //Variables added in 1.1
        
        //Showing the password on screen
        if let showPasswordOnScreenNumber = aDecoder.decodeObjectOfClass(NSNumber.self, forKey: showPasswordOnScreenKey) {
            showPasswordOnScreen = showPasswordOnScreenNumber.boolValue
        }
        
        //Variables added in 1.2
        
        //If night mode is enabled
        if let nightModeEnabledNumber = aDecoder.decodeObjectOfClass(NSNumber.self, forKey: nightModeEnabledKey) {
            nightModeEnabled = nightModeEnabledNumber.boolValue
        }
        
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        let firstTimeOpeningAppNumber = NSNumber(bool: firstTimeOpeningApp)
        aCoder.encodeObject(firstTimeOpeningAppNumber, forKey: firstTimeOpeningAppKey)
        
        let encryptionEnabledNumber = NSNumber(bool: encryptionEnabled)
        aCoder.encodeObject(encryptionEnabledNumber, forKey: encryptionEnabledKey)
        
        aCoder.encodeObject(encryptionPassword, forKey: encryptionPasswordKey)
        
        let showPasswordOnScreenNumber = NSNumber(bool: showPasswordOnScreen)
        aCoder.encodeObject(showPasswordOnScreenNumber, forKey: showPasswordOnScreenKey)
        
        let nightModeEnabledNumber = NSNumber(bool: nightModeEnabled)
        aCoder.encodeObject(nightModeEnabledNumber, forKey: nightModeEnabledKey)
    }
    
    //MARK: - NSSecureCoding
    class func supportsSecureCoding() -> Bool {
        return true
    }
}