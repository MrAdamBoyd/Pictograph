//
//  PictographImageCoder.m
//  Pictograph
//
//  Created by Adam on 2015-10-04.
//  Copyright © 2015 Adam Boyd. All rights reserved.
//

#import "PictographImageCoder.h"
@import RNCryptor_objc;

#if TARGET_OS_IPHONE
#import "Pictograph-Swift.h"
#else
#import "Pictograph_Mac-Swift.h"
#endif

#define bitCountForCharacter 8
#define bitsChangedPerPixel 2
#define bitCountForInfo 16
#define bytesPerPixel 4
#define maxIntFor8Bits 255
#define maxFloatFor8Bits 255.0

@implementation PictographImageCoder

#if TARGET_OS_OSX
@synthesize isCancelled;
#endif

#pragma mark Decoding a message hidden in an image

//Decodes UIImage image. Returns the encoded message in the image.
//Password handler has no parameters and returns an NSString *
- (NSString *)decodeMessageInImage:(PictographImage *)image encryptedWithPassword:(NSString *)password error:(NSError **)error {
    
    DLog("Decoding image with password %@", password);
    
    NSMutableArray *infoArrayInBits = [[NSMutableArray alloc] init];
    
    //Getting information about the encoded message
    NSArray *first8PixelsInfo = [self getRBGAFromImage:image atX:0 andY:0 count:(bitCountForInfo / bitsChangedPerPixel)];
    for (PictographColor *color in first8PixelsInfo) {
        //Going through each color that contains information about the message
        [self addBlueBitsFromColor:color toArray:infoArrayInBits];
    }
    
    long informationAboutString = [self longFromBits:infoArrayInBits];
    
    BOOL messageIsEncrypted = NO;
    
    //Using 16 bits for future proofing
    //Only using 1 bit right now
    /*
     (0) 00000000 00000000 - Normal message, proceed as normal
     (1) 00000000 00000001 - Encrypted message
     */
    switch (informationAboutString) {
        case 0:
            messageIsEncrypted = NO;
            break;
            
        case 1:
            messageIsEncrypted = YES;
            
            if ([password isEqualToString:@""]) {
                //The message is encrypted and the user has no password entered, alert user
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"The image you provided is encrypted and you didn't provide a password. Please enter the password."};
                *error = [NSError errorWithDomain:PictographErrorDomain code:NoPasswordProvidedError userInfo:userInfo];
                return nil;
            }
            
            break;
            
        default: {
            //If there was an error, alert the user
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"The image you provided does not contain a hidden message."};
            *error = [NSError errorWithDomain:PictographErrorDomain code:NoMessageInImageError userInfo:userInfo];
            return nil;
        }
    }
    
    //Sending the analytics
    [[PictographDataController shared] analyticsDecodeSend:messageIsEncrypted];
    
    //Message is not encrypted, send with blank password
    return [self messageFromImage:image needsPassword:messageIsEncrypted password:password error:error];
}

//Returns the message from the image given an optional password
- (NSString *)messageFromImage:(PictographImage *)image needsPassword:(BOOL)isEncrypted password:(NSString *)password error:(NSError **)error {
    
    NSMutableString *decodedString = [[NSMutableString alloc] init];
    NSMutableArray *sizeArrayInBits = [[NSMutableArray alloc] init];
    
    //Getting the size of the string
    NSArray *first8PixelsColors = [self getRBGAFromImage:image atX:8 andY:0 count:(bitCountForInfo / bitsChangedPerPixel)];
    
    for (PictographColor *color in first8PixelsColors) {
        //Going through each color that contains the size of the message
        [self addBlueBitsFromColor:color toArray:sizeArrayInBits];
    }
    
    long numberOfBitsNeededForImage = [self longFromBits:sizeArrayInBits];
    
    //Going through all the pixels to get the char value
    
    NSMutableArray *arrayOfBitsForMessage = [[NSMutableArray alloc] init];
    NSMutableData *encryptedData = [[NSMutableData alloc] init];
    
    NSArray *arrayOfColors = [self getRBGAFromImage:image atX:16 andY:0 count:((int)numberOfBitsNeededForImage / bitsChangedPerPixel)];
    
    for (PictographColor *color in arrayOfColors) {
        //Going through each pixel
        [self addBlueBitsFromColor:color toArray:arrayOfBitsForMessage];
        
        if ([arrayOfBitsForMessage count] == bitCountForCharacter) {
            //If there are now enough bits to make a char
            
            long longChar = [self longFromBits:arrayOfBitsForMessage];
            
            if (isEncrypted) {
                //If the string is encrypted, add it to the encrypted data
                char curChar = (char)longChar;
                
                [encryptedData appendBytes:&curChar length:1];
                
            } else {
                //Not encrypted, just add it to string
                [decodedString appendFormat:@"%c", (char)longChar];
            }
            
            [arrayOfBitsForMessage removeAllObjects]; //Reset the array for the next char
        }
    }
    
    if (isEncrypted) {
        //If message is encrypted, decrypt it and save it
        NSError *decryptError = nil;
        NSData *encodedString = [RNDecryptor decryptData:encryptedData withPassword:password error:&decryptError];
        decodedString = [[NSMutableString alloc] initWithData:encodedString encoding:NSUTF8StringEncoding];
        
        if (decryptError) {
            //If there was an error, alert the user
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"The password you entered was incorrect. Please try again."};
            *error = [NSError errorWithDomain:PictographErrorDomain code:PasswordIncorrectError userInfo:userInfo];
            return nil;
        }
    }
    
    //Sending the analytics
    [[PictographDataController shared] analyticsDecodeSend:isEncrypted];
    
    return decodedString;

}

//Adds the last 2 bits of the blue value from PictographColor color to the NSMutableArray array
- (void)addBlueBitsFromColor:(PictographColor *)color toArray:(NSMutableArray *)array {
    CGFloat red, green, blue, alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    
    NSArray *arrayOfBitsFromBlue = [self binaryStringFromInteger:(blue * maxIntFor8Bits) withSpaceFor:bitCountForCharacter];
    
    [array addObject:[arrayOfBitsFromBlue objectAtIndex:6]];
    [array addObject:[arrayOfBitsFromBlue objectAtIndex:7]];
}

#pragma mark Encoding message in an image

//Encodes UIImage image with message message. Returns the modified UIImage
- (NSData *)encodeMessage:(NSString *)message inImage:(PictographImage *)image encryptedWithPassword:(NSString *)password error:(NSError **)error {

    DLog("Encoding message: %@, with password %@", message, password);
    
    NSString *toEncode = [[NSMutableString alloc] init];
    
    BOOL encryptedBool = ![password isEqualToString:@""];
    
    if (encryptedBool) {
        //If the user wants to encrypt the string, encrypt it
        NSError *error;
        NSData *stringData = [message dataUsingEncoding:NSUTF8StringEncoding];
        NSData *cipherData = [RNEncryptor encryptData:stringData withSettings:kRNCryptorAES256Settings password:password error:&error];
        const char *bytes = [cipherData bytes];
        NSMutableString *stringOfBytes = [[NSMutableString alloc] init];
        
        for (int i = 0; i < [cipherData length]; i++) {
            //Converting the data into bytes to it can easily be converted into bits
            [stringOfBytes appendFormat:@"%c", bytes[i]];
        }
        
        toEncode = [NSString stringWithString:stringOfBytes];
        
    } else {
        //No need to encode
        toEncode = message;
    }
    
    int maxMessageLengthForImage = ((int)[image getReconciledImageWidth] * (int)[image getReconciledImageHeight]) / 8;
    if ([message length] > maxMessageLengthForImage) {
        //Makes sure message length is under
        DLog(@"User's message was too large: %lu characters", (unsigned long)[message length]);
        
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"Your message was too large. Please shorten your message or split it into multple images."};
        *error = [NSError errorWithDomain:PictographErrorDomain code:ImageTooSmallError userInfo:userInfo];
        
        return nil;
    }
    
    /* Note: the actual number of pixels needed is higher than this because the length of the string needs to be
     stored, but this isn't included in the calculations */
    long numberOfBitsNeeded = [toEncode length] * bitCountForCharacter; //8 bits to a char
    long numberOfPixelsNeeded = (numberOfBitsNeeded / 2) + (bitCountForInfo / 2) + (bitCountForInfo / 2);
    
    if (([image getReconciledImageHeight] * [image getReconciledImageWidth]) <= numberOfPixelsNeeded) {
        //Makes sure the image is large enough to handle the message
        DLog(@"User's selected image was too small");
        
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"Image was too small, please select a larger image."};
        
        *error = [NSError errorWithDomain:PictographErrorDomain code:MessageTooLongError userInfo:userInfo];
        
        return nil;
    }
    
    /* Adding the size of the message here. Always using 16 bits for the size, even though it might only require 8,
     giving a maximum size of 2^16 bits, or 65536 chars. Preceded by 8 bits of information regarding message */
    NSMutableArray *arrayOfBits = [[NSMutableArray alloc] init];
    
    //Using 16 bits for future proofing
    //Only using 1 bit right now
    /*
     (0) 00000000 00000000 - Normal message, proceed as normal
     (1) 00000000 00000001 - Encrypted message
     */
    
    int encryptedOrNotBit = encryptedBool ? 1 : 0;
    
    [arrayOfBits addObjectsFromArray:[self binaryStringFromInteger:encryptedOrNotBit withSpaceFor:bitCountForInfo]]; //16 bits for future proofing
    
    [arrayOfBits addObjectsFromArray:[self binaryStringFromInteger:(int)numberOfBitsNeeded withSpaceFor:bitCountForInfo]]; //16 bits for spacing
    
    for (int charIndex = 0; charIndex < [toEncode length]; charIndex++) {
        //Going through each character
        
        char curChar = [toEncode characterAtIndex:charIndex];
        [arrayOfBits addObjectsFromArray:[self binaryStringFromInteger:curChar withSpaceFor:bitCountForCharacter]]; //Only 8 bits needed for chars
        
    }
    
    return [self saveImageToGraphicsContextAndEncodeBitsInImage:image numberOfBitsNeeded:numberOfBitsNeeded arrayOfBits:arrayOfBits];
}

    
#if TARGET_OS_IPHONE
//Saves the image to the graphics context and starts encoding the bits in that image
- (NSData *)saveImageToGraphicsContextAndEncodeBitsInImage:(PictographImage *)image numberOfBitsNeeded:(long)numberOfBitsNeeded arrayOfBits:(NSMutableArray *)arrayOfBits {
    //Right here we have all the bits that are needed to encode the data in the image
    
    NSUInteger imageWidth = [image getReconciledImageWidth];
    NSUInteger imageHeight = [image getReconciledImageHeight];
    
    CGRect imageRect = CGRectMake(0, 0, imageWidth, imageHeight);
    
    UIGraphicsBeginImageContext(CGSizeMake(imageWidth, imageHeight));
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    NSArray *arrayOfAllNeededColors = [self getRBGAFromImage:image atX:0 andY:0 count:(int)numberOfBitsNeeded];
    int encodeCounter = 0; //Counter which bit we are encoding, goes up 2 with each inner loop
    
    /**
     *  When images are taken with the camera, sometimes they are given in incorrect image orientatin value (usually straight up images are given the orientation of right), so this deals with having them rotated incorrectly
     */
    if (image.imageOrientation == UIImageOrientationRight) {
        [image drawAtPoint:CGPointMake(0,0)];
        
        //Save current status of graphics context
        CGContextSaveGState(context);

        //Changing all pixel colors
        for (int heightCounter = 1; heightCounter < imageHeight; heightCounter++) {
            for (int widthCounter = 0; widthCounter < imageWidth; widthCounter++){
                //Going through each bit 2 by 2, that means we need to encode the pixel at position
                //(encodeCounter/2 [assuming it's an array]) with data at encodeCounter and encodeCounter + 1
                
                if (encodeCounter >= [arrayOfBits count]) {
                    //If the message has been fully encoded, break
                    CGContextRestoreGState(context);
                    
                    //Returning a PNG of the image, as PNG as lossless
                    return UIImagePNGRepresentation(UIGraphicsGetImageFromCurrentImageContext());
                }
                
                DLog(@"at %i, %i", widthCounter, (heightCounter - 1));
                
                encodeCounter = [self changePixelValueAtWidth:widthCounter andHeight:heightCounter encodeCounter:encodeCounter arrayOfColors:arrayOfAllNeededColors arrayOfBits:arrayOfBits image:image withinContext:context startFromBottomLeft:false];
            }
        }
        
    } else {
        //A lot of OS X libraries use the lower left corner as (0,0), this is transforming the image to be rightside up
        //http://stackoverflow.com/questions/506622/cgcontextdrawimage-draws-image-upside-down-when-passed-uiimage-cgimage
        CGContextTranslateCTM(context, 0, imageHeight);
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextDrawImage(context, imageRect, [image CGImage]);
    
        //Save current status of graphics context
        CGContextSaveGState(context);

        //Changing all the pixel colors
        for (int heightCounter = (int)imageHeight; heightCounter >= 0; heightCounter--) {
            for (int widthCounter = 0; widthCounter < imageWidth; widthCounter++){
                //Going through each bit 2 by 2, that means we need to encode the pixel at position
                //(encodeCounter/2 [assuming it's an array]) with data at encodeCounter and encodeCounter + 1
                
                if (encodeCounter >= [arrayOfBits count]) {
                    //If the message has been fully encoded, break
                    CGContextRestoreGState(context);
                    
                    //Returning a PNG of the image, as PNG as lossless
                    return UIImagePNGRepresentation(UIGraphicsGetImageFromCurrentImageContext());
                }
                
                DLog(@"Pixel change at %i, %i", widthCounter, (int)(imageHeight - heightCounter));
                
                encodeCounter = [self changePixelValueAtWidth:widthCounter andHeight:heightCounter encodeCounter:encodeCounter arrayOfColors:arrayOfAllNeededColors arrayOfBits:arrayOfBits image:image withinContext:context startFromBottomLeft:true];
            }
        }
    }
    
    CGContextRestoreGState(context);
    return nil;
}
#else
- (NSData *)saveImageToGraphicsContextAndEncodeBitsInImage:(PictographImage *)image numberOfBitsNeeded:(long)numberOfBitsNeeded arrayOfBits:(NSMutableArray *)arrayOfBits {
    CGImageRef imageRef = [image getReconciledCGImageRef];
    NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc] initWithCGImage: imageRef];
    
    NSArray *arrayOfAllNeededColors = [self getRBGAFromImage:image atX:0 andY:0 count:(int)numberOfBitsNeeded];
    
    int encodeCounter = 0; //Counter which bit we are encoding, goes up 2 with each inner loop
    PictographColor *pixelColor;
    
    NSUInteger imageWidth = [image getReconciledImageWidth];
    NSUInteger imageHeight = [image getReconciledImageHeight];
    
    for (int heightCounter = 0; heightCounter < imageHeight; heightCounter++) {
        for (int widthCounter = 0; widthCounter < imageWidth; widthCounter++) {
            //Going through each bit 2 by 2, that means we need to encode the pixel at position
            //(encodeCounter/2 [assuming it's an array]) with data at encodeCounter and encodeCounter + 1
            
            if (encodeCounter >= [arrayOfBits count] || self.isCancelled) {
                //If the message has been fully encoded or if the operation is cancelled, break out
                
                return [imageRep representationUsingType:NSPNGFileType properties: [[NSDictionary alloc] init]];
                
            }
            
            DLog(@"Pixel change at %i, %i", widthCounter, heightCounter);
            
            pixelColor = [self newPixelColorValueAtWidth:widthCounter andHeight:(heightCounter + 1) encodeCounter:encodeCounter arrayOfColors:arrayOfAllNeededColors arrayOfBits:arrayOfBits image:image startFromBottomLeft:false];
            
            
            /*
             The next line is commented out and the next few (until encodeCounter +=...) are added as a workaround. I was getting a colorspace error when trying to use [imageRep setColor:]. Colorspace was -1 and component count was -1. I tried using this:
             
             CGFloat colorComponents[] = {red, green, newBlueValue, alpha};
             return [PictographColor colorWithColorSpace:[NSColorSpace sRGBColorSpace] components:colorComponents count:4];
             
             but that didn't work either. This was the only workaround I could find that was relatively easy.
             
             */
//            [imageRep setColor:pixelColor atX:widthCounter y:heightCounter];
            CGFloat red, green, blue, alpha;
            [pixelColor getRed:&red green:&green blue:&blue alpha:&alpha];
            NSUInteger pix[4]; pix[0] = red * 255; pix[1] = green * 255; pix[2] = blue * 255; pix[3] = alpha * 255;
            [imageRep setPixel:pix atX:widthCounter y:heightCounter];
            
            //2 bits are encoded per pixel, so per pixel, bump the encode counter by 2
            encodeCounter += bitsChangedPerPixel;
        }
    }
    
    return nil;
}
#endif

//Replaces the value of the color at the current width and height counter with the correct one from the array of bits that are needed to be encoded
- (int)changePixelValueAtWidth:(int)widthCounter andHeight:(int)heightCounter encodeCounter:(int)encodeCounter arrayOfColors:(NSArray *)arrayOfAllNeededColors arrayOfBits:(NSArray *)arrayOfBits image:(PictographImage *)image withinContext:(CGContextRef)context startFromBottomLeft:(BOOL)startFromBottomLeft {
    PictographColor *newColorAtPixel = [self newPixelColorValueAtWidth:widthCounter andHeight:heightCounter encodeCounter:encodeCounter arrayOfColors:arrayOfAllNeededColors arrayOfBits:arrayOfBits image:image startFromBottomLeft:startFromBottomLeft];
    
    CGFloat red, green, blue, alpha;
    [newColorAtPixel getRed:&red green:&green blue:&blue alpha:&alpha];
    
    CGContextSetRGBFillColor(context, red, green, blue, alpha);
    CGContextFillRect(context, CGRectMake(widthCounter, heightCounter - 1, 1, 1)); //Only filling in 1 pixel
    
    encodeCounter += bitsChangedPerPixel; //2 bits per pixel, so increase by 2
    
    return encodeCounter;
}

//Gets the color that the specified pixel should be
-(PictographColor *)newPixelColorValueAtWidth:(int)widthCounter andHeight:(int)heightCounter encodeCounter:(int)encodeCounter arrayOfColors:(NSArray *)arrayOfAllNeededColors arrayOfBits:(NSArray *)arrayOfBits image:(PictographImage *)image startFromBottomLeft:(BOOL)startFromBottomLeft {
    int currentPixelIndex;
    
    //If we're starting from the bottom left, take the height of the image into account, if not, can just use the height counter provided
    if (startFromBottomLeft) {
        currentPixelIndex = widthCounter * ((int)[image getReconciledImageHeight] - heightCounter + 1);
    } else {
        currentPixelIndex = widthCounter * heightCounter;
    }
    
    PictographColor *colorOfCurrentPixel = [arrayOfAllNeededColors objectAtIndex:currentPixelIndex];
    CGFloat red, green, blue, alpha ;
    [colorOfCurrentPixel getRed:&red green:&green blue:&blue alpha:&alpha];
    
    //Changing the value of the blue byte
    NSMutableArray *arrayOfBitsFromBlue = [[NSMutableArray alloc] initWithArray:[self binaryStringFromInteger:blue * maxIntFor8Bits withSpaceFor:bitCountForCharacter]];
    
    //Changing the least significant bits of the blue byte
    [arrayOfBitsFromBlue replaceObjectAtIndex:6 withObject:arrayOfBits[encodeCounter]];
    [arrayOfBitsFromBlue replaceObjectAtIndex:7 withObject:arrayOfBits[encodeCounter + 1]];
    
    long newBlueLong = [self longFromBits:arrayOfBitsFromBlue];
    CGFloat newBlueValue = (newBlueLong * 1.0) / maxIntFor8Bits;

    return [PictographColor colorWithRed:red green:green blue:newBlueValue alpha:alpha];
}

#pragma mark Methods used for both encoding and decoding

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
    
    NSArray *sizeInBits = [bitArray subarrayWithRange:NSMakeRange(0, bitCountForInfo)];
    NSMutableString *sizeInBitsString = [[NSMutableString alloc] init];
    
    for (int sizeCounter = 0; sizeCounter < bitCountForInfo; sizeCounter++) {
        //Creating a single string with the size, easily convertible to an int
        [sizeInBitsString appendString:[NSString stringWithFormat:@"%@", [sizeInBits objectAtIndex:sizeCounter]]];
    }
    
    NSArray *characterArrayInBits = [bitArray subarrayWithRange:NSMakeRange(bitCountForInfo, [bitArray count] - bitCountForInfo)];
    for (int charBitCounter = 0; charBitCounter < [bitArray count] - bitCountForInfo; charBitCounter += bitCountForCharacter) {
        //Going through each character
        NSArray *singleCharacterArray = [characterArrayInBits subarrayWithRange:NSMakeRange(charBitCounter, bitCountForCharacter)];

        long decimalRepresentationOfChar = [self longFromBits:singleCharacterArray];
        char curChar = (char)decimalRepresentationOfChar;
        
        [message appendFormat:@"%c", curChar];
    }
    
    return message;
}

/* Returns the long representation of a bit array
   For example ("1101" -> 13) */
-(long)longFromBits:(NSArray *)bitArray {
    
    NSMutableString *singleCharacterArrayInBits = [[NSMutableString alloc] init];
    
    for (int singleCharCounter = 0; singleCharCounter < [bitArray count]; singleCharCounter++) {
        //Creating a string of the bits that make up this one character, this is easily convertible to a char
        [singleCharacterArrayInBits appendString:[NSString stringWithFormat:@"%@", [bitArray objectAtIndex:singleCharCounter]]];
    }
    
    long longRep = strtol([singleCharacterArrayInBits UTF8String], NULL, 2);
    
    return longRep;
}

/* Returns an array of PictographColors for the pixels starting at x, y for count number of pixels
   http://stackoverflow.com/questions/448125/how-to-get-pixel-data-from-a-uiimage-cocoa-touch-or-cgimage-core-graphics
   Used the above link as inspiration, but heavily modified */
-(NSArray *)getRBGAFromImage:(PictographImage*)image atX:(int)x andY:(int)y count:(int)count {
    
    //Getting the raw data
    unsigned char *rawData = [self getRawPixelDataForImage:image];
    
    NSUInteger width = [image getReconciledImageWidth];
    
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger byteIndex = (bytesPerRow * y) + x * bytesPerPixel;
    
    NSMutableArray *colorArray = [[NSMutableArray alloc] init];
    
    for (int counter = 0; counter < count; counter++) {
        //Getting the bits for each color space red, green, blue, and alpha
        CGFloat red   = (rawData[byteIndex]     * 1.0) / maxFloatFor8Bits;
        CGFloat green = (rawData[byteIndex + 1] * 1.0) / maxFloatFor8Bits;
        CGFloat blue  = (rawData[byteIndex + 2] * 1.0) / maxFloatFor8Bits;
        CGFloat alpha = (rawData[byteIndex + 3] * 1.0) / maxFloatFor8Bits;
        byteIndex += bytesPerPixel;
        
        PictographColor *newColor = [PictographColor colorWithRed:red green:green blue:blue alpha:alpha];
        
        [colorArray addObject:newColor];
        
    }
    
    free(rawData);
    
    return colorArray;
}

/* Returns the raw pixel data for a UIImage image */
-(unsigned char *)getRawPixelDataForImage:(PictographImage *)image {
    // First get the image into your data buffer
    
    CGImageRef imageRef = [image getReconciledCGImageRef];
    
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    return rawData;
}

@end
