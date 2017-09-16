//
//  PictographImageCoderProgressDelegate.h
//  Pictograph
//
//  Created by Adam on 9/13/17.
//  Copyright © 2017 Adam Boyd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PictographImageCoderProgressDelegate <NSObject>

- (void)pictographImageCoderDidUpdateProgress:(float)progress;

@end
