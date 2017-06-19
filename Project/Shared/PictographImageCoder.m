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
#define bitCountForHiddenDataSize 64 //Number of bits needed, NOT pixels
#define bytesPerPixel 4
#define componentsPerPixel 4
#define maxIntFor8Bits 255
#define maxFloatFor8Bits 255.0

@implementation PictographImageCoder

@synthesize isCancelled;

#pragma mark Decoding a messages and images hidden in an image

//Decodes a string from an image. Returns nil if there is no message in the image or if there was an error
- (void)decodeImage:(PictographImage * _Nonnull)image encryptedWithPassword:(NSString * _Nonnull)password hiddenStringPointer:(NSString * _Nullable * _Nullable)hiddenString hiddenImagePointer:(PictographImage * _Nullable * _Nullable)hiddenImage error:(NSError * _Nullable * _Nullable)error {
    
    BOOL dataIsImage;
    NSData *dataFromImage = [self decodeDataInImage:image encryptedWithPassword:password dataIsImage:&dataIsImage error:error];
    
    if (dataIsImage) {
        *hiddenImage = [[PictographImage alloc] initWithData:dataFromImage];
    } else {
        //In addition to converting the string back to a readable version, this converts any unicode scalars back to readable format (like emoji)
        *hiddenString = [[NSString alloc] initWithData:dataFromImage encoding:NSNonLossyASCIIStringEncoding];
    }
}

//Decodes UIImage image. Returns the encoded data in the image
//Password handler has no parameters and returns an NSString *
- (NSData * _Nullable)decodeDataInImage:(PictographImage * _Nonnull)image encryptedWithPassword:(NSString * _Nonnull)password dataIsImage:(BOOL *)dataIsImage error:(NSError * _Nullable * _Nullable)error {
    
    DLog("Decoding image with password %@", password);
    
    NSMutableArray *infoArrayInBits = [[NSMutableArray alloc] init];
    
    //Getting information about the encoded message
    const NSArray *first8PixelsBlueComponents = [self getBlueComponentsFromImage:image atX:0 andY:0 count:[self pixelCountForBit:bitCountForInfo]];
    for (NSNumber *blueComponent in first8PixelsBlueComponents) {
        //Going through each color that contains information about the message
        [self addLastBitsFromBlueComponent:blueComponent toArray:infoArrayInBits];
    }
    
    const long informationAboutString = [self longFromBits:infoArrayInBits];
    
    BOOL dataIsEncrypted = NO;
    *dataIsImage = NO;
    
    //Using 16 bits for future proofing
    //Only using 2 bits right now
    /*
     (0) 00000000 00000000 - Normal message, proceed as normal
     (1) 00000000 00000001 - Encrypted message
     (2) 00000000 00000010 - Normal image, proceed as normal
     (3) 00000000 00000011 - NOT SUPPORTED: Images can't be encrypted
     */
    switch (informationAboutString) {
        case 0:
            dataIsEncrypted = NO;
            break;
            
        case 1:
            dataIsEncrypted = YES;
            
            if ([password isEqualToString:@""]) {
                //The message is encrypted and the user has no password entered, alert user
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"The image you provided is encrypted and you didn't provide a password. Please enter the password."};
                *error = [NSError errorWithDomain:PictographErrorDomain code:NoPasswordProvidedError userInfo:userInfo];
                return nil;
            }
            
            break;
            
        case 2:
            *dataIsImage = YES;
            break;
            
        default: {
            //If there was an error, alert the user
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"The image you provided does not contain a hidden message."};
            *error = [NSError errorWithDomain:PictographErrorDomain code:NoMessageInImageError userInfo:userInfo];
            return nil;
        }
    }
    
    //Sending the analytics
    [[PictographDataController shared] analyticsDecodeSend:dataIsEncrypted];
    
    //Message is not encrypted, send with blank password
    return [self dataFromImage:image needsPassword:dataIsEncrypted password:password error:error];
}

//Returns the message from the image given an optional password
- (NSData *)dataFromImage:(PictographImage *)image needsPassword:(BOOL)isEncrypted password:(NSString *)password error:(NSError **)error {
    
    NSMutableArray *sizeArrayInBits = [[NSMutableArray alloc] init];
    
    //Getting the size of the string
    NSArray *blueComponentsContainingSizeOfImage = [self getBlueComponentsFromImage:image atX:[self pixelCountForBit:bitCountForInfo] andY:0 count:[self pixelCountForBit:bitCountForHiddenDataSize]];
    
    for (NSNumber *blueComponent in blueComponentsContainingSizeOfImage) {
        //Going through each color that contains the size of the message
        [self addLastBitsFromBlueComponent:blueComponent toArray:sizeArrayInBits];
    }
    
    long numberOfBitsNeededForImage = [self longFromBits:sizeArrayInBits];
    
    //Going through all the pixels to get the char value
    
    NSMutableArray *arrayOfBitsForMessage = [[NSMutableArray alloc] init];
    NSMutableData *dataFromImage = [[NSMutableData alloc] init];
    NSData *toReturn;
    
    int firstPixelWithHiddenData = [self pixelCountForBit:(bitCountForInfo + bitCountForHiddenDataSize)];
    NSArray *arrayOfBlueComponents = [self getBlueComponentsFromImage:image atX:firstPixelWithHiddenData andY:0 count:[self pixelCountForBit:(int)numberOfBitsNeededForImage]];
    
    for (NSNumber *blueComponent in arrayOfBlueComponents) {
        //Going through each pixel
        [self addLastBitsFromBlueComponent:blueComponent toArray:arrayOfBitsForMessage];
        
        if ([arrayOfBitsForMessage count] == bitCountForCharacter) {
            //If there are now enough bits to make a char
            
            long longChar = [self longFromBits:arrayOfBitsForMessage];
            
            char curChar = (char)longChar;
            
            [dataFromImage appendBytes:&curChar length:1];
            
            [arrayOfBitsForMessage removeAllObjects]; //Reset the array for the next char
        }
    }
    
    if (isEncrypted) {
        //If message is encrypted, decrypt it and save it
        NSError *decryptError = nil;
        toReturn = [RNDecryptor decryptData:dataFromImage withPassword:password error:&decryptError];
        
        if (decryptError) {
            //If there was an error, alert the user
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"The password you entered was incorrect. Please try again."};
            *error = [NSError errorWithDomain:PictographErrorDomain code:PasswordIncorrectError userInfo:userInfo];
            return nil;
        }
    } else {
        toReturn = dataFromImage;
    }
    
    //Sending the analytics
    [[PictographDataController shared] analyticsDecodeSend:isEncrypted];
    
    return toReturn;

}

//Adds the last 2 bits of the blue value from PictographColor color to the NSMutableArray array
- (void)addLastBitsFromBlueComponent:(NSNumber *)blueComponent toArray:(NSMutableArray *)array {
    NSArray *arrayOfBitsFromBlue = [self binaryStringFromInteger:blueComponent.unsignedCharValue withSpaceFor:bitCountForCharacter];
    
    [array addObject:[arrayOfBitsFromBlue objectAtIndex:6]];
    [array addObject:[arrayOfBitsFromBlue objectAtIndex:7]];
}

#pragma mark Encoding messages and images

//Encodes UIImage image with message message. Returns the modified UIImage or NSImage
- (NSData * _Nullable)encodeMessage:(NSString * _Nonnull)message inImage:(PictographImage * _Nonnull)image encryptedWithPassword:(NSString * _Nonnull)password error:(NSError * _Nullable * _Nullable)error {
    
    DLog("Encoding message: %@, with password %@", message, password);
    
    //Converting emoji to the unicode scalars
    NSData *unicodeMessageData = [message dataUsingEncoding:NSNonLossyASCIIStringEncoding];
    
    return [self encodeData:unicodeMessageData dataIsImage:NO inImage:image encryptedWithPassword:password error:error];
    
}

//Encodes an image within another image
- (NSData * _Nullable)encodeImage:(PictographImage * _Nonnull)hiddenImage inImage:(PictographImage * _Nonnull)image error:(NSError * _Nullable * _Nullable)error {
    const CGSize originalSize = CGSizeMake([hiddenImage getReconciledImageWidth], [hiddenImage getReconciledImageHeight]);
    CGSize newSize = [self determineSizeForHidingImage:hiddenImage withinImage:image];
    
    PictographImage *imageToHide = hiddenImage;
    
    if (originalSize.width != newSize.width && originalSize.height != newSize.height) {
        //If the hidden image needs to be resized
        DLog(@"Hidden image needs to be this size, resizing: width: %f, height: %f", newSize.width, newSize.height);
        
        imageToHide = [imageToHide scaledImageWithNewSize:newSize];
    }
    
    NSData *dataFromImageToHide = [imageToHide dataRepresentation];
    
    return [self encodeData:dataFromImageToHide dataIsImage:YES inImage:image encryptedWithPassword:@"" error:error];
}

#pragma mark Helper methods for encoding a message in an image

//Encodes UIImage image with the data. Returns modified UIImage or NSImage
- (NSData * _Nullable)encodeData:(NSData * _Nonnull)data dataIsImage:(BOOL)dataIsImage inImage:(PictographImage * _Nonnull)image encryptedWithPassword:(NSString * _Nonnull)password error:(NSError * _Nullable * _Nullable)error {
    
    NSData *dataToEncode;
    
    BOOL encryptedBool = ![password isEqualToString:@""];
    
    if (encryptedBool) {
        //If the user wants to encrypt the string, encrypt it
        NSError *error;
        dataToEncode = [RNEncryptor encryptData:data withSettings:kRNCryptorAES256Settings password:password error:&error];
        
    } else {
        //No need to encode
        dataToEncode = data;
    }
    
    /* Note: the actual number of pixels needed is higher than this because the length of the string needs to be
     stored, but this isn't included in the calculations */
    long bitsNeededForData = [dataToEncode length] * bitCountForCharacter; //8 bits to a char
    long numberOfPixelsNeeded = [self pixelCountForBit:(bitCountForInfo + bitCountForHiddenDataSize + (int)bitsNeededForData)];
    
    if (([image getReconciledImageHeight] * [image getReconciledImageWidth]) <= numberOfPixelsNeeded) {
        //Makes sure the image is large enough to handle the message
        DLog(@"User's selected image was too small");
        
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"Image was too small, please select a larger image."};
        
        *error = [NSError errorWithDomain:PictographErrorDomain code:ImageTooSmallError userInfo:userInfo];
        
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
     (2) 00000000 00000010 - Normal image, proceed as normal
     (3) 00000000 00000011 - NOT SUPPORTED: Images can't be encrypted
     */
    
    int encryptedOrNotBit = encryptedBool ? 1 : 0;
    encryptedOrNotBit += dataIsImage ? 2 : 0;
    
    [arrayOfBits addObjectsFromArray:[self binaryStringFromInteger:encryptedOrNotBit withSpaceFor:bitCountForInfo]]; //16 bits for future proofing
    
    [arrayOfBits addObjectsFromArray:[self binaryStringFromInteger:(int)bitsNeededForData withSpaceFor:bitCountForHiddenDataSize]]; //64 bits for size
    
    const char *bytes = [dataToEncode bytes];
    for (int charIndex = 0; charIndex < [dataToEncode length]; charIndex++) {
        //Going through each character
        
        char curChar = bytes[charIndex];
        [arrayOfBits addObjectsFromArray:[self binaryStringFromInteger:curChar withSpaceFor:bitCountForCharacter]]; //Only 8 bits needed for chars
        
    }
    
    return [self saveImageToGraphicsContextAndEncodeBitsInImage:image arrayOfBits:arrayOfBits];
}


//Saves the image to the graphics context and starts encoding the bits in that image
- (NSData *)saveImageToGraphicsContextAndEncodeBitsInImage:(PictographImage *)image arrayOfBits:(NSMutableArray *)arrayOfBits {
    //Right here we have all the bits that are needed to encode the data in the image
    
    NSUInteger imageWidth = [image getReconciledImageWidth];
    NSUInteger imageHeight = [image getReconciledImageHeight];
    
    int numberOfPixelsNeeded = [self pixelCountForBit:(int)[arrayOfBits count]];
    NSArray *arrayOfBlueComponents = [self getBlueComponentsFromImage:image atX:0 andY:0 count:numberOfPixelsNeeded];
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    size_t bitsPerComponent = 8;
    size_t bytesPerRow = bytesPerPixel * imageWidth;
    
    //Aligns the pixel data to unsigned char * aka UInt. Each item in the array is a component of each pixel. So every 4 is a pixel. See docs for getRawPixelDataForImage:
    unsigned char *pixelBuffer = [self getRawPixelDataForImage:image];
    
    int encodeCounter = 0; //Counter which bit we are encoding, goes up 2 with each pixel
    
    //Need numberOfPixelsNeeded * 4 due to this array counting by components of each pixel (RGBA)
    for (int i = 0; i < (numberOfPixelsNeeded * 4); i += 4) {
        
        
        if ([self isCancelled]) {
            //Break out of loop
            break;
        }
        
        int pixelIndex = i / 4;
        UInt8 newBlueComponent = [self newBlueComponentValueAtIndex:pixelIndex encodeCounter:encodeCounter arrayOfBlueComponents:arrayOfBlueComponents arrayOfBits:arrayOfBits image:image];
        
        pixelBuffer[i+2] = newBlueComponent;
        
        DLog(@"Changing pixel value at index %i", pixelIndex);
        
        encodeCounter += 2;
    }
    
    CGContextRef editedBitmap = CGBitmapContextCreate(pixelBuffer, imageWidth, imageHeight, bitsPerComponent, bytesPerRow, colorspace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Little);
    
    //Getting the image from the bitmap
    NSData *dataRepresentationOfModifiedImage;
    CGImageRef outputImage = CGBitmapContextCreateImage(editedBitmap);
    
    //CGImageRef to NSData
#if TARGET_OS_IPHONE
    UIImage *encodedImage = [[UIImage alloc] initWithCGImage:outputImage];
    dataRepresentationOfModifiedImage = UIImagePNGRepresentation(encodedImage);
#else
    CFMutableDataRef newImageData = CFDataCreateMutable(NULL, 0);
    CGImageDestinationRef destination = CGImageDestinationCreateWithData(newImageData, kUTTypePNG, 1, NULL);
    CGImageDestinationAddImage(destination, outputImage, nil);
    CGImageDestinationFinalize(destination);
    dataRepresentationOfModifiedImage = (__bridge_transfer NSData *)newImageData;
    
    CFRelease(destination);
#endif
    
    //Freeing the memory
    CGColorSpaceRelease(colorspace);
    CGContextRelease(editedBitmap);
    free(pixelBuffer);
    
    return dataRepresentationOfModifiedImage;
    
}

//Gets the color that the specified pixel should be
-(UInt8)newBlueComponentValueAtIndex:(int)index encodeCounter:(int)encodeCounter arrayOfBlueComponents:(NSArray *)arrayOfAllNeededBlueComponents arrayOfBits:(NSArray *)arrayOfBits image:(PictographImage *)image {
    
    NSNumber *blueNSNumber = [arrayOfAllNeededBlueComponents objectAtIndex:index];
    unsigned char blueComponent = blueNSNumber.unsignedCharValue;
    
    //Changing the value of the blue byte
    NSMutableArray *arrayOfBitsFromBlue = [[NSMutableArray alloc] initWithArray:[self binaryStringFromInteger:blueComponent withSpaceFor:bitCountForCharacter]];
    
    //Changing the least significant bits of the blue byte
    [arrayOfBitsFromBlue replaceObjectAtIndex:6 withObject:arrayOfBits[encodeCounter]];
    [arrayOfBitsFromBlue replaceObjectAtIndex:7 withObject:arrayOfBits[encodeCounter + 1]];
    
    long newBlueLong = [self longFromBits:arrayOfBitsFromBlue];

    return (UInt8)newBlueLong;
}

# pragma mark Helper methods used for hiding an image within another image

/**
 Determines the size that the hidden image will need to be in order to fit in the original image. Instead of figuring out the exact size that will make the image fit, it cuts the scale factor in half each time. Starting with 1, then 1/2, then 1/4 etc
 
 @param hiddenImage image to hide
 @param image image that the hiddenImage will be hidden in
 @return factor that hiddenImage needs to be scaled by
 */
- (CGSize)determineSizeForHidingImage:(PictographImage *)hiddenImage withinImage:(PictographImage *)image {
    const NSUInteger numberOfPixelsInMainImage = [image getReconciledImageWidth] * [image getReconciledImageHeight];
    CGFloat scaleFactor = 1;
    
    CGSize hiddenImageSize = CGSizeMake([hiddenImage getReconciledImageWidth] * scaleFactor, [hiddenImage getReconciledImageHeight] * scaleFactor);
    NSUInteger pixelsNeededForHiddenImage = [self numberOfPixelsNeededToHideImageOfSize:hiddenImageSize];
    
    while (pixelsNeededForHiddenImage >= numberOfPixelsInMainImage) {
        //Cut the width and height of the image in half each time
        scaleFactor = scaleFactor / 2;
        
        hiddenImageSize = CGSizeMake([hiddenImage getReconciledImageWidth] * scaleFactor, [hiddenImage getReconciledImageHeight] * scaleFactor);
        pixelsNeededForHiddenImage = [self numberOfPixelsNeededToHideImageOfSize:hiddenImageSize];
    }
    
    return hiddenImageSize;
}

/**
 This is the number of pixels that it would take to hide the specified image, including the information bits about the image
 
 @param imageSize size of the image not counting retina displays
 @return number of pixels it would take to encode all information
 */
- (NSUInteger)numberOfPixelsNeededToHideImageOfSize:(CGSize)imageSize {
    
    //Number of bits needed to encode a single pixel worth of information
    NSUInteger bitsNeededPerPixel = bitCountForCharacter * bytesPerPixel;
    NSUInteger bitsNeededToEncodeEntireImage = bitsNeededPerPixel * imageSize.width * imageSize.height;
    
    //16 bits for info about image, 64 bits for number of bits needed
    NSUInteger totalBitsToEncode = bitCountForInfo + bitCountForHiddenDataSize + bitsNeededToEncodeEntireImage;
    
    return totalBitsToEncode / bitsChangedPerPixel;
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

/* Returns the long representation of a bit array
   For example (["1", "1", "0", "1"] -> 13) */
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
-(NSArray *)getBlueComponentsFromImage:(PictographImage*)image atX:(int)x andY:(int)y count:(int)count {
    
    //Getting the raw data
    unsigned char *rawData = [self getRawPixelDataForImage:image];
    
    NSMutableArray *blueComponentArray = [[NSMutableArray alloc] init];
    
    NSUInteger width = [image getReconciledImageWidth];
    
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger byteIndex = (bytesPerRow * y) + x * bytesPerPixel;
    
    for (int counter = 0; counter < count; counter++) {
        //Getting the bits for each color space red, green, blue, and alpha
        unsigned char blueComponent = rawData[byteIndex + 2];
        
        byteIndex += bytesPerPixel;
        
        [blueComponentArray addObject:[NSNumber numberWithUnsignedChar:blueComponent]];
        
    }
    
    free(rawData);
    
    return blueComponentArray;
}

/* Returns the raw pixel data for a UIImage image */
//This returns a (void *) of the pixel data from this image. By casting it as an array of unsigned char, we can easily access the RGBA values of each pixel. This also makes it easy to iterate over the entire image as well.
//  (assuming i % 4 == 0)
//  pixelBuffer[i] is the red
//  pixelBuffer[i+1] is the green
//  pixelBuffer[i+2] is the blue
//  pixelBuffer[i+3] is the alpha
-(unsigned char *)getRawPixelDataForImage:(PictographImage *)image {
    // First get the image into your data buffer
    
    CGImageRef imageRef = [image getReconciledCGImageRef];
    
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Little);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    
    //Freeing the memory
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    return rawData;
}

#pragma mark Dealing with bits

/**
 Returns the corresponding pixel for the specified bit
 
 @param bit bit number that we're looking at
 @return pixel that count be changed
 */
- (int)pixelCountForBit:(int)bit {
    return bit / bitsChangedPerPixel;
}

@end
