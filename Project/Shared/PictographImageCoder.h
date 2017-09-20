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
#import "PictographImage+Resize.h"
#import "PictographImageCoderProgressDelegate.h"

@interface PictographImageCoder : NSObject

//If the operation should be cancelled and return with whatever progress has been made
@property (atomic, assign) BOOL isCancelled;

@property (nonatomic, weak) id<PictographImageCoderProgressDelegate> _Nullable delegate;

- (id _Nonnull)initWithDelegate:(id<PictographImageCoderProgressDelegate> _Nullable)delegate;

//Messages

/**
 Decodes a message or image that was previously encoded with the PictographImageCoder

 @param image image where the message is located
 @param password nullable password, if null, no password assumed. If it is determined that an image is hidden, password will be ignored
 @param hiddenString pointer to the string hidden in the image, if there is one
 @ param hiddenImage pointer to the image hidden in the image, if there is one
 @param error pointer to an error
 */
- (void)decodeImage:(PictographImage * _Nonnull)image encryptedWithPassword:(NSString * _Nonnull)password hiddenStringPointer:(NSString * _Nullable * _Nullable)hiddenString hiddenImagePointer:(PictographImage * _Nullable * _Nullable)hiddenImage error:(NSError * _Nullable * _Nullable)error;


/**
 Encodes a message inside of an image

 @param message message to encode in the image
 @param image image to hide the message in
 @param password password to encrypt the message with. Sets the encrypt bit to true. If null, assume no password
 @param error pointer to an error
 @return NSData representation of the UIImage or NSImage with the message encoded in the image's pixels
 */
- (NSData * _Nullable)encodeMessage:(NSString * _Nonnull)message inImage:(PictographImage * _Nonnull)image encryptedWithPassword:(NSString * _Nonnull)password error:(NSError * _Nullable * _Nullable)error NS_SWIFT_NAME(encode(message:in:encryptedWithPassword:));

/**
 Encodes an image inside of an image
 
 @param hiddenImage image to encode in the image
 @param image image to hide the image in
 @param shrinkImageMore if true, shrinks the image more for faster encoding
 @param error pointer to an error
 @return NSData representation of the UIImage or NSImage with the message encoded in the image's pixels
 */
- (NSData * _Nullable)encodeImage:(PictographImage * _Nonnull)hiddenImage inImage:(PictographImage * _Nonnull)image shrinkImageMore:(BOOL)shrinkImageMore error:(NSError * _Nullable * _Nullable)error NS_SWIFT_NAME(encode(image:in:shrinkImageMore:));

@end
