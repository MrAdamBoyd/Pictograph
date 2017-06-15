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
 Takes the image and transforms it into nsdata that can be transformed back into a pictograph image
 
 @return NSData representation of the pictograph image
 */
- (NSData *_Nullable)dataRepresentation;

/**
 Gets the CGImageRef for the UIImage or NSImage

 @return CGImageRef
 */
- (CGImageRef _Nullable)getReconciledCGImageRef;


/**
 Gets the width for the iamge. Doesn't use image.size.width but gets it from the CGImageRef for UIImage and the NSBitMapImageRef for the NSImage

 @return actual width of the image in pixels, not points (200x200 image will return 200 regardless of density of user's display)
 */
- (NSUInteger)getReconciledImageWidth;

/**
 Gets the width for the iamge. Doesn't use image.size.height but gets it from the CGImageRef for UIImage and the NSBitMapImageRef for the NSImage
 
 @return actual height of the image in pixels, not points (200x200 image will return 200 regardless of density of user's display)
 */
- (NSUInteger)getReconciledImageHeight;

@end
