//
//  UIImageCoder.m
//  Pictograph
//
//  Created by Adam on 2015-10-04.
//  Copyright © 2015 Adam Boyd. All rights reserved.
//

#import "UIImageCoder.h"

#define bitCountForCharacter 8
#define bitCountForSize 16

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
    long numberOfBitsNeeded = [message length] * bitCountForCharacter; //8 bits to a char
    long numberOfPixelsNeeded = numberOfBitsNeeded / 2; //Storing 2 bits per pixel, so 4 pixels per char
    
    //TODO: Check if image is large enough
    
    /* Adding the size of the message here. Always using 16 bits for the size, even though it might only require 8,
     giving a maximum size of 2^16 bits, or 65536 chars */
    NSMutableArray *arrayOfBits = [[NSMutableArray alloc] init];
    [arrayOfBits addObjectsFromArray:[self binaryStringFromInteger:(int)numberOfBitsNeeded withSpaceFor:bitCountForSize]]; //16 bits for spacing
    
    for (int charIndex = 0; charIndex < [message length]; charIndex++) {
        //Going through each character
        
        char curChar = [message characterAtIndex:charIndex];
        [arrayOfBits addObjectsFromArray:[self binaryStringFromInteger:curChar withSpaceFor:bitCountForCharacter]]; //Only 8 bits needed for chars
        
    }
    
    [self stringFromBits:arrayOfBits];
    
    //TODO: Add 2 bits to each pixel
    
    [self getRGBAFromImage:image atX:0 andY:0];
    
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

/* Returns the binary representation of a character */
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

/* Returns the string based on the length provided in the first 16 bits of the bit array */
-(NSString *)stringFromBits:(NSArray *)bitArray {
    NSMutableString *message = [[NSMutableString alloc] init];
    
    NSArray *sizeInBits = [bitArray subarrayWithRange:NSMakeRange(0, bitCountForSize)];
    NSMutableString *sizeInBitsString = [[NSMutableString alloc] init];
    
    //TODO: We need to know the size before we get to this stage, but this is just for building the function
    for (int sizeCounter = 0; sizeCounter < bitCountForSize; sizeCounter++) {
        //Creating a single string with the size, easily convertible to an int
        [sizeInBitsString appendString:[NSString stringWithFormat:@"%@", [sizeInBits objectAtIndex:sizeCounter]]];
    }
    
    NSArray *characterArrayInBits = [bitArray subarrayWithRange:NSMakeRange(bitCountForSize, [bitArray count] - bitCountForSize)]; //TODO: This won't be necessary, we can use whole string when done
    for (int charBitCounter = 0; charBitCounter < [bitArray count] - bitCountForSize; charBitCounter += bitCountForCharacter) {
        //Going through each character
        NSArray *singleCharacterArray = [characterArrayInBits subarrayWithRange:NSMakeRange(charBitCounter, bitCountForCharacter)];
        NSMutableString *singleCharacterArrayInBits = [[NSMutableString alloc] init];
        
        for (int singleCharCounter = 0; singleCharCounter < [singleCharacterArray count]; singleCharCounter++) {
            //Creating a string of the bits that make up this one character, this is easily convertible to a char
            [singleCharacterArrayInBits appendString:[NSString stringWithFormat:@"%@", [singleCharacterArray objectAtIndex:singleCharCounter]]];
        }
        
        //Getting the decimal representation ("1101" -> 13)
        long decimalRepresentationOfChar = strtol([singleCharacterArrayInBits UTF8String], NULL, 2);
        char curChar = (char)decimalRepresentationOfChar;
        
        [message appendFormat:@"%c", curChar];
    }
    
    
    return message;
}

/* Returns the bit representation of the RBGA values for a pixel at x, y */
//http://stackoverflow.com/questions/448125/how-to-get-pixel-data-from-a-uiimage-cocoa-touch-or-cgimage-core-graphics
//Used the above link as inspiration, but heavily modified
-(NSArray*)getRGBAFromImage:(UIImage*)image atX:(int)x andY:(int)y {
    
    // First get the image into your data buffer
    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    // Now your rawData contains the image data in the RGBA8888 pixel format.
    NSUInteger byteIndex = (bytesPerRow * y) + x * bytesPerPixel;

    NSMutableArray *bitArrayOfPixel = [[NSMutableArray alloc] init];
    
    //Getting the bits for each color space red, green, blue, and alpha
    [bitArrayOfPixel addObjectsFromArray:[self binaryStringFromInteger:(rawData[byteIndex + 0] * 1.0) withSpaceFor:bitCountForCharacter]]; //Red
    [bitArrayOfPixel addObjectsFromArray:[self binaryStringFromInteger:(rawData[byteIndex + 1] * 1.0) withSpaceFor:bitCountForCharacter]]; //Green
    [bitArrayOfPixel addObjectsFromArray:[self binaryStringFromInteger:(rawData[byteIndex + 2] * 1.0) withSpaceFor:bitCountForCharacter]]; //Blue
    [bitArrayOfPixel addObjectsFromArray:[self binaryStringFromInteger:(rawData[byteIndex + 3] * 1.0) withSpaceFor:bitCountForCharacter]]; //Alpha
    
    free(rawData);
    
    return bitArrayOfPixel;
}

@end
