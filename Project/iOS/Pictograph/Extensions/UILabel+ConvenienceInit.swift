//
//  UILabel+ConvenienceInit.swift
//  Pictograph
//
//  Created by Adam Boyd on 2017/6/12.
//  Copyright © 2017 Adam Boyd. All rights reserved.
//

import Foundation

extension UILabel {
    convenience init(text: String, font: UIFont) {
        self.init()
        
        self.text = text
        self.font = font
    }
}
