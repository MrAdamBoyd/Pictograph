//
//  AppDelegateExtention.swift
//  BlurInactiveScreen
//
//  Created by Nikolay Shubenkov on 21/05/15.
//  Copyright (c) 2015 Nikolay Shubenkov. All rights reserved.
//

//https://github.com/NikolayShubenkovProgSchool/BlurAppWindow-Swift

import UIKit

//some random number
private let blurViewtag = 198489

extension AppDelegate {
    
    func blurPresentedView() {
        //return if bluered view with hardcoded tag is added to main window
        if (self.window?.viewWithTag(blurViewtag) != nil){
            return
        }
        
        let snapshot  = bluredSnapshot();
        self.window?.addSubview(snapshot!)
    }
    
    //find and remove blured view
    func unblurPresentedView() {
        self.window?.viewWithTag(blurViewtag)?.removeFromSuperview()
    }
    
    func bluredSnapshot () -> UIView? {
        //take window snapshot
        //and add blurView to it
        let snapshot = self.window?.snapshotView(afterScreenUpdates: true)
        snapshot?.addSubview(blurView((snapshot?.frame)!))
        snapshot?.tag = blurViewtag
        return snapshot
    }
    
    func blurView(_ frame: CGRect) -> UIView {
        //iOS 8 and later
        switch UIDevice.current.systemVersion.compare("8.0.0", options: NSString.CompareOptions.numeric) {
        case .orderedSame, .orderedDescending:
            let view    = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
            view.frame  = frame
            return view
            //Other
        case .orderedAscending:
            let toolbar      = UIToolbar(frame: frame)
            toolbar.barStyle = UIBarStyle.blackTranslucent;
            return toolbar
        }
    }
}
