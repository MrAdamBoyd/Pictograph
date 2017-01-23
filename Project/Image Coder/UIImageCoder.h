//
//  UIImageCoder.h
//  Pictograph
//
//  Created by Adam on 2015-10-04.
//  Copyright © 2015 Adam Boyd. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "EncodingErrors.h"

@interface UIImageCoder : NSObject

//Messages
- (NSString * _Nullable)decodeMessageInImage:(UIImage * _Nonnull)image encryptedWithPassword:(NSString * _Nullable)password error:(NSError * _Nullable * _Nullable)error;
- (NSData * _Nullable)encodeMessage:(NSString * _Nonnull)message inImage:(UIImage * _Nonnull)image encryptedWithPassword:(NSString * _Nullable)password error:(NSError * _Nullable * _Nullable)error;

@end
