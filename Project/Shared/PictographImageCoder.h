//
//  PictographImageCoder.h
//  Pictograph
//
//  Created by Adam on 2015-10-04.
//  Copyright © 2015 Adam Boyd. All rights reserved.
//

#import "TargetConditionals.h"
#import <Foundation/Foundation.h>
#import "EncodingErrors.h"
#import "PictographImage+Reconciliation.h"
#import "Global.h"

@interface PictographImageCoder : NSObject

#if TARGET_OS_OSX
//If the operation should be cancelled and return with whatever progress has been made
@property (atomic, assign) BOOL isCancelled;
#endif

//Messages

/**
 Decodes a message that was previously encoded with the PictographImageCoder

 @param image image where the message is located
 @param password nullable password, if null, no password assumed
 @param error pointer to an error
 @return nullable string that contains the message if it was decoded correctly
 */
- (NSString * _Nullable)decodeMessageInImage:(PictographImage * _Nonnull)image encryptedWithPassword:(NSString * _Nonnull)password error:(NSError * _Nullable * _Nullable)error;


/**
 Encodes a message inside of an image

 @param message message to encode in the image
 @param image image to hide the message in
 @param password password to encrypt the message with. Sets the encrypt bit to true. If null, assume no password
 @param error pointer to an error
 @return NSData representation of the UIImage or NSImage with the message encoded in the image's pixels
 */
- (NSData * _Nullable)encodeMessage:(NSString * _Nonnull)message inImage:(PictographImage * _Nonnull)image encryptedWithPassword:(NSString * _Nonnull)password error:(NSError * _Nullable * _Nullable)error;

@end
