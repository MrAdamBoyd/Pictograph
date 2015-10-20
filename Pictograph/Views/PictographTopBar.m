//
//  PictographTopBar.m
//  Pictograph
//
//  Created by Adam Boyd on 2015-10-17.
//  Copyright © 2015 Adam Boyd. All rights reserved.
//

#import "PictographTopBar.h"

@implementation PictographTopBar

@synthesize titleLabel;

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        //Adding app title to UIView at top of screen
        titleLabel = [[UILabel alloc] init];
        titleLabel.font = [UIFont boldSystemFontOfSize:24];
        titleLabel.textColor = [UIColor whiteColor];
        [self addSubview:titleLabel];
        [titleLabel setTranslatesAutoresizingMaskIntoConstraints:false];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        
        //Centered on X and centered on Y
        [self addConstraint:[NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:5]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:65]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:-65]];
        
        [titleLabel setText:@"Pictograph"];
    }
    
    return self;
}

@end
