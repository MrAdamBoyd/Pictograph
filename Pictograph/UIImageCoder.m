//
//  UIImageCoder.m
//  Pictograph
//
//  Created by Adam on 2015-10-04.
//  Copyright © 2015 Adam Boyd. All rights reserved.
//

#import "UIImageCoder.h"

@implementation UIImageCoder

//Decodes UIImage image. Returns the encoded message in the image.
- (NSString *)decodeImage:(UIImage *)image {
    
    NSString *decodedString = @"";
    return decodedString;
    
}

//Encodes UIImage image with message message. Returns the modified UIImage
- (UIImage *)encodeImage:(UIImage *)image withMessage:(NSString *)message {

    UIImage *encodedImage = [[UIImage alloc] init];
    return encodedImage;
    
    /*
     figure out how many bits needed (# of chars * 4)
     convert number to bits
     convert number to have 8 bits
     split into 4 groups of 2
     encode that number in first 4 pixels
     for char in message
        translate char into 8 bits (8 bits per byte)
            split 8 bits into 4 groups of 2
            for group in groups
                convert pixel into bits
                2 least significant bits = group bits
     */

}

@end
