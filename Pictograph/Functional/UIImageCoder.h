//
//  UIImageCoder.h
//  Pictograph
//
//  Created by Adam on 2015-10-04.
//  Copyright © 2015 Adam Boyd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "EncodingErrors.h"
@import RNCryptor;

@interface UIImageCoder : NSObject

//Messages
- (NSString * _Nullable)decodeMessageInImage:(UIImage * _Nonnull)image encryptedWithPassword:(NSString * _Nullable)password error:(NSError * _Nonnull * _Nonnull)error;
- (NSData * _Nullable)encodeMessage:(NSString * _Nonnull)message inImage:(UIImage * _Nonnull)image encryptedWithPassword:(NSString * _Nullable)password error:(NSError * _Nonnull * _Nonnull)error;

- (NSData * _Nullable)decodeImageInImage:(UIImage * _Nonnull)image encryptedWithPassword:(NSString * _Nullable)password error:(NSError * _Nonnull * _Nonnull)error;
- (NSData * _Nullable)encodeImage:(UIImage * _Nonnull)imageToHide withinImage:(UIImage * _Nonnull)image encryptedWithPassword:(NSString * _Nullable)password error:(NSError * _Nonnull * _Nonnull)error;

@end
