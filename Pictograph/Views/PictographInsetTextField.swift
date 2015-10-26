//
//  PictographInsetTextField.swift
//  Pictograph
//
//  Created by Adam Boyd on 2015-10-25.
//  Copyright © 2015 Adam Boyd. All rights reserved.
//

import Foundation
import UIKit

private let inset: CGFloat = 10
private let cornerRadius: CGFloat = 2

@objc
class PictographInsetTextField: UITextField {
    let inset: CGFloat = 10
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = cornerRadius
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //Placeholder position
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, inset , inset)
    }
    
    //Text position
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, inset , inset)
    }
}