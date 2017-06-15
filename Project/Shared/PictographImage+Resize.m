//
//  PictographImage+Resize.m
//  Pictograph
//
//  Created by Adam Boyd on 2017/6/14.
//  Copyright © 2017 Adam Boyd. All rights reserved.
//

#import "PictographImage+Resize.h"

@implementation PictographImage (Resize)

- (PictographImage *)scaledImageWithNewSize:(CGSize)newSize {
#if TARGET_OS_IPHONE
    CGImageRef cgImage = [self CGImage];
    size_t bitsPerComponent = CGImageGetBitsPerComponent(cgImage);
    size_t bytesPerRow = CGImageGetBytesPerRow(cgImage);
    CGColorSpaceRef colorRef = CGImageGetColorSpace(cgImage);
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(cgImage);
    
    CGContextRef context = CGBitmapContextCreate(nil, newSize.width, newSize.height, bitsPerComponent, bytesPerRow, colorRef, bitmapInfo);
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    
    CGContextDrawImage(context, CGRectMake(0, 0, newSize.width, newSize.height), cgImage);
    
    return [[UIImage alloc] initWithCGImage:CGBitmapContextCreateImage(context)];
#else
    NSImage *sourceImage = [self copy];
    NSImage *smallImage = [[NSImage alloc] initWithSize: newSize];
    [smallImage lockFocus];
    [sourceImage setSize: newSize];
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
    [sourceImage drawAtPoint:NSZeroPoint fromRect:CGRectMake(0, 0, newSize.width, newSize.height) operation:NSCompositeCopy fraction:1.0];
    [smallImage unlockFocus];
    return smallImage;
#endif
}

@end
