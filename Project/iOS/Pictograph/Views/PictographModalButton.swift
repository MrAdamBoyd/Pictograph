//
//  PictographModalButton.swift
//  Pictograph
//
//  Created by Adam on 10/8/17.
//  Copyright © 2017 Adam Boyd. All rights reserved.
//

import Foundation
import UIKit

class PictographModalButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.commonInit()
    }
    
    private func commonInit() {
        self.setTitleColor(.blue, for: .normal)
        self.setTitleColor(UIColor.blue.withAlphaComponent(0.5), for: .highlighted)
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.blue.cgColor
    }
}
