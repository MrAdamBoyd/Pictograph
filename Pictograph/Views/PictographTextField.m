//
//  PictographTextField.m
//  Pictograph
//
//  Created by Adam Boyd on 2015-10-19.
//  Copyright © 2015 Adam Boyd. All rights reserved.
//

#import "PictographTextField.h"

#define kCornerRadius 2.0
#define kInset 10

@implementation PictographTextField

- (id)init {
    if (self = [super init]) {
        self.layer.cornerRadius = kCornerRadius;
    }
    
    return self;
}

#pragma mark UITextField

- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, kInset, kInset);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, kInset, kInset);
}

@end
