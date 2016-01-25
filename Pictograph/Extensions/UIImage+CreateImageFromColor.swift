//
//  UIImage+CreateImageFromColor.swift
//  Pictograph
//
//  Created by Adam Boyd on 2016-01-24.
//  Copyright © 2016 Adam Boyd. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    convenience init(color: UIColor, size: CGSize = CGSizeMake(1, 1)) {
        let rect = CGRectMake(0, 0, size.width, size.height)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(CGImage: image.CGImage!)
    }  
}