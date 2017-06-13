//
//  CreatesNavigationTitle.swift
//  Pictograph
//
//  Created by Adam Boyd on 2016-01-24.
//  Copyright © 2016 Adam Boyd. All rights reserved.
//

import Foundation

private let titleFontSize: CGFloat = 24

protocol CreatesNavigationTitle {
    func createNavigationTitle(_ text: String) -> UIView
}

extension CreatesNavigationTitle {
    func createNavigationTitle(_ text: String) -> UIView {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.boldSystemFont(ofSize: titleFontSize)
        titleLabel.textColor = UIColor.white
        titleLabel.text = text
        titleLabel.sizeToFit()
        
        return titleLabel
    }
}
