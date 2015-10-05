//
//  UIImageCoder.h
//  Pictograph
//
//  Created by Adam on 2015-10-04.
//  Copyright © 2015 Adam Boyd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIImageCoder : NSObject

- (NSString *)decodeImage:(UIImage *)image;
- (UIImage *)encodeImage:(UIImage *)image withMessage:(NSString *)message;

@end
