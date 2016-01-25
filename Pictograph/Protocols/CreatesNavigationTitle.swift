//
//  CreatesNavigationTitle.swift
//  Pictograph
//
//  Created by Adam Boyd on 2016-01-24.
//  Copyright © 2016 Adam Boyd. All rights reserved.
//

import Foundation

private let titleFontSize:CGFloat = 24

protocol CreatesNavigationTitle {
    func createNavigationTitle(text: String) -> UIView
}

extension CreatesNavigationTitle {
    func createNavigationTitle(text: String) -> UIView {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.boldSystemFontOfSize(titleFontSize)
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = text
        titleLabel.sizeToFit()
        
        return titleLabel
    }
}