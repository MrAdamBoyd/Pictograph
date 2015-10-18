//
//  PictographButton.m
//  Pictograph
//
//  Created by Adam Boyd on 2015-10-18.
//  Copyright © 2015 Adam Boyd. All rights reserved.
//

#import "PictographButton.h"

@implementation PictographButton

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    if (highlighted) {
        self.backgroundColor = [self.backgroundColor colorWithAlphaComponent:0.8];
    }
    else {
        self.backgroundColor = [UIColor whiteColor];
    }
}

@end
