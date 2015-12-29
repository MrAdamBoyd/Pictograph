//
//  PictographHighlightedButton.swift
//  Pictograph
//
//  Created by Adam Boyd on 2015-10-25.
//  Copyright © 2015 Adam Boyd. All rights reserved.
//

import Foundation
import UIKit

@objc
class PictographHighlightButton: UIButton {
    
    var highlightColor = UIColor.whiteColor()
    
    override var highlighted: Bool {
        didSet {
            if (highlighted) {
                if let bgColor = self.backgroundColor {
                    self.backgroundColor = bgColor.colorWithAlphaComponent(0.8)
                }
            }
            else {
                self.backgroundColor = self.highlightColor
            }
        }
    }
    
}