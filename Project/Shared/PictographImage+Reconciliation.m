//
//  PictographImage+Reconciliation.m
//  Pictograph
//
//  Created by Adam Boyd on 17/4/14.
//  Copyright © 2017 Adam Boyd. All rights reserved.
//

#import "PictographImage+Reconciliation.h"

@implementation PictographImage (Reconciliation)

- (CGImageRef) getReconciledCGImageRef {
#if TARGET_OS_IPHONE
    return [self CGImage];
#else
    NSRect imageRect = NSMakeRect(0, 0, self.size.width, self.size.height);
    return [self CGImageForProposedRect: &imageRect context:NULL hints:nil];
#endif
}

- (NSUInteger) getReconciledImageWidth {
#if TARGET_OS_IPHONE
    CGImageRef imageRef = [self CGImage];
    return CGImageGetWidth(imageRef);
#else
    NSData *data = [self TIFFRepresentation];
    NSBitmapImageRep *bitmap = [NSBitmapImageRep imageRepWithData:data];
    return bitmap.pixelsWide;
#endif
}

- (NSUInteger) getReconciledImageHeight {
#if TARGET_OS_IPHONE
    CGImageRef imageRef = [self CGImage];
    return CGImageGetHeight(imageRef);
#else
    NSData *data = [self TIFFRepresentation];
    NSBitmapImageRep *bitmap = [NSBitmapImageRep imageRepWithData:data];
    return bitmap.pixelsHigh;
#endif
}

@end
