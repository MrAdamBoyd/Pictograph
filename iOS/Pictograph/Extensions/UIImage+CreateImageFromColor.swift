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
    convenience init(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: image!.cgImage!)
    }  
}
