//
//  UIImageCoder.h
//  Pictograph
//
//  Created by Adam on 2015-10-04.
//  Copyright © 2015 Adam Boyd. All rights reserved.
//

#if TARGET_OS_MAC
#import <Cocoa/Cocoa.h>
#define PictographImage NSImage
#elif TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#define PictographImage UIImage
#endif

#import <Foundation/Foundation.h>
#import "EncodingErrors.h"

@interface UIImageCoder : NSObject

//Messages
- (NSString * _Nullable)decodeMessageInImage:(PictographImage * _Nonnull)image encryptedWithPassword:(NSString * _Nullable)password error:(NSError * _Nullable * _Nullable)error;
- (NSData * _Nullable)encodeMessage:(NSString * _Nonnull)message inImage:(PictographImage * _Nonnull)image encryptedWithPassword:(NSString * _Nullable)password error:(NSError * _Nullable * _Nullable)error;

@end
