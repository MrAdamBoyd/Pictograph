//
//  IntroViewBuilder.swift
//  Pictograph
//
//  Created by Adam Boyd on 2015-10-26.
//  Copyright © 2015 Adam Boyd. All rights reserved.
//

import Foundation
import EAIntroView

//Constants for the intro view
private let introViewTitleFont = UIFont.systemFont(ofSize: 35)
private let introViewDescFont = UIFont.systemFont(ofSize: 20)
private let introViewTitleY = UIScreen.main.bounds.height - 50
private let introViewDescY = UIScreen.main.bounds.height - 100
private let introPage1Color = UIColor(red: 24/255.0, green: 120/255.0, blue: 217/255.0, alpha: 1)
private let introPage2Color = UIColor(red: 220/255.0, green: 141/255.0, blue: 56/255.0, alpha: 1)

class IntroView {
    class func buildIntroViews() -> [EAIntroPage] {
        var introViewArray: [EAIntroPage] = []
        
        if (PictographDataController.shared.getUserFirstTimeOpeningApp()) {
            //Introducing the app
            let page1 = EAIntroPage()
            page1.title = "Steganography"
            page1.titleFont = introViewTitleFont
            page1.titlePositionY = introViewTitleY
            page1.desc = "Steganography is the practice of hiding messages.\n\nUsing Pictograph, you can hide messages in images, and the images won't look any different."
            page1.descFont = introViewDescFont
            page1.descPositionY = introViewDescY
            page1.bgColor = introPage1Color
            introViewArray.append(page1)
            
            //Asking for permission for GPS while using the app
            let page2 = EAIntroPage()
            page2.title = "Encryption";
            page2.titleFont = introViewTitleFont
            page2.titlePositionY = introViewTitleY
            page2.desc = "Pictograph also allows you to encrypt your messages. You will have to give the password to whoever you want to read the message."
            page2.descFont = introViewDescFont
            page2.descPositionY = introViewDescY
            page2.bgColor = introPage2Color
            introViewArray.append(page2)
        }
        
        return introViewArray
    }
}
