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
    
    var highlightColor = UIColor.white
    
    override var isHighlighted: Bool {
        didSet {
            if self.isHighlighted {
                self.backgroundColor = self.backgroundColor?.withAlphaComponent(0.8)
            } else {
                self.backgroundColor = self.highlightColor
            }
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            if isEnabled {
                //If enabled, set all alphas to 1.0
                self.alpha = 1.0
            
            } else {
                //If disabled, set alphas to 0.5
                self.alpha = 0.5
            }
        }
    }
    
}
