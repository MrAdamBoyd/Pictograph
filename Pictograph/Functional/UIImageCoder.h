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
#import "PictographDataController.h"
@import RNCryptor;

@interface UIImageCoder : NSObject

- (NSString * _Nonnull)decodeImage:(UIImage * _Nonnull)image encryptedWithPassword:(NSString * _Nullable)password error:(NSError * _Nonnull * _Nonnull)error;
- (NSData * _Nonnull)encodeImage:(UIImage * _Nonnull)image withMessage:(NSString * _Nonnull)message encrypted:(BOOL)encryptedBool withPassword:(NSString *_Nonnull)password error:(NSError * _Nonnull * _Nonnull)error;

@end
