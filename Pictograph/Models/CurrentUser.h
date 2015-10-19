//
//  CurrentUser.h
//  Pictograph
//
//  Created by Adam Boyd on 2015-10-19.
//  Copyright © 2015 Adam Boyd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CurrentUser : NSObject <NSCoding, NSSecureCoding>

@property(nonatomic, assign) BOOL firstTimeOpeningApp;
@property(nonatomic, assign) BOOL encryptionEnabled;
@property(nonatomic, strong) NSString *encryptionKey;

@end
