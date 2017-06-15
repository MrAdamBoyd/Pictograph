//
//  PictographImage+Reconciliation.m
//  Pictograph
//
//  Created by Adam Boyd on 17/4/14.
//  Copyright © 2017 Adam Boyd. All rights reserved.
//

#import "PictographImage+Reconciliation.h"

@implementation PictographImage (Reconciliation)

- (NSData *)dataRepresentation {
#if TARGET_OS_IPHONE
    return UIImagePNGRepresentation(self);
#else
    CGImageRef imageRef = [self getReconciledCGImageRef];
    NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc] initWithCGImage: imageRef];
    return [imageRep representationUsingType:NSPNGFileType properties: [[NSDictionary alloc] init]];
#endif
}

- (CGImageRef)getReconciledCGImageRef {
#if TARGET_OS_IPHONE
    return [self CGImage];
#else
    NSRect imageRect = NSMakeRect(0, 0, [self getReconciledImageWidth], [self getReconciledImageHeight]);
    return [self CGImageForProposedRect: &imageRect context:NULL hints:nil];
#endif
}

- (NSUInteger)getReconciledImageWidth {
#if TARGET_OS_IPHONE
    return self.size.width * self.scale;
#else
    NSImageRep *rep = [[self representations] objectAtIndex:0];
    return [rep pixelsWide];
#endif
}

- (NSUInteger)getReconciledImageHeight {
#if TARGET_OS_IPHONE
    return self.size.height * self.scale;
#else
    NSImageRep *rep = [[self representations] objectAtIndex:0];
    return [rep pixelsHigh];
#endif
}

@end
