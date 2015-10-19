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

- (NSString *)decodeImage:(UIImage *)image error:(NSError **)error;
- (NSData *)encodeImage:(UIImage *)image withMessage:(NSString *)message encrypted:(BOOL)encryptedBool withPassword:(NSString *)password error:(NSError **)error;

@end
