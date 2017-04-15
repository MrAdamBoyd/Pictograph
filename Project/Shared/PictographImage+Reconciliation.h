//
//  PictographImage+Reconciliation.h
//  Pictograph
//
//  Created by Adam Boyd on 17/4/14.
//  Copyright © 2017 Adam Boyd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Global.h"

@interface PictographImage (Reconciliation)


/**
 Gets the CGImageRef for the UIImage or NSImage

 @return CGImageRef
 */
- (CGImageRef) getReconciledCGImageRef;


/**
 Gets the width for the iamge. Doesn't use image.size.width but gets it from the CGImageRef for UIImage and the NSBitMapImageRef for the NSImage

 @return actual width of the image in pixels, not points (200x200 image will return 200 regardless of density of user's display)
 */
- (NSUInteger) getReconciledImageWidth;

@end
