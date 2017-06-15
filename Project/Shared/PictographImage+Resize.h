//
//  PictographImage+Resize.h
//  Pictograph
//
//  Created by Adam Boyd on 2017/6/14.
//  Copyright © 2017 Adam Boyd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Global.h"

@interface PictographImage (Resize)

/**
 Returns a scaled version of the image
 
 @return new size of the image. Doesn't need to be the same aspect ratio
 */
- (PictographImage *)scaledImageWithNewSize:(CGSize)newSize;

@end
