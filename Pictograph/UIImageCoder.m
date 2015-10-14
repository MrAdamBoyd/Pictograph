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

    /* Note: the actual number of pixels needed is higher than this because the length of the string needs to be
     stored, but this isn't included in the calculations */
    long numberOfBitsNeeded = [message length] * 8; //8 bits to a char
    long numberOfPixelsNeeded = numberOfBitsNeeded / 2; //Storing 2 bits per pixel, so 4 pixels per char
    
    
    /* Adding the size of the message here. Always using 16 bits for the size, even though it might only require 8,
     giving a maximum size of 2^16 bits, or 65536 chars */
    NSMutableArray *arrayOfBits = [[NSMutableArray alloc] init];
    [arrayOfBits addObjectsFromArray:[self binaryStringFromInteger:(int)numberOfBitsNeeded withSpaceFor:16]]; //16 bits for spacing
    
    for (int charIndex = 0; charIndex < [message length]; charIndex++) {
        //Going through each character
        
        char curChar = [message characterAtIndex:charIndex];
        [arrayOfBits addObjectsFromArray:[self binaryStringFromInteger:curChar withSpaceFor:8]]; //Only 8 bits needed for chars
        
    }
    
    //TODO: Add 2 bits to each pixel
    
    UIImage *encodedImage = [[UIImage alloc] init];
    return encodedImage;
    
    /*
     figure out how many pixels needed (# of chars * 4)
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

//http://stackoverflow.com/questions/655792/how-to-convert-nsinteger-to-a-binary-string-value
//Used the above link as information, but instead decided to use an int array and remove spacing
-(NSArray *)binaryStringFromInteger:(int)number withSpaceFor:(int)numberOfBits{
    NSMutableArray *bitArray = [[NSMutableArray alloc] init];
    int binaryDigit = 0;
    int integer = number;
    
    while(binaryDigit < numberOfBits) {
        //Going through each binary digit
        binaryDigit++;
        
        [bitArray insertObject:((integer & 1) ? @1 : @0) atIndex:0];
        
        integer = integer >> 1;
    }
    
    return bitArray;
}

@end
