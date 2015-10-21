//
//  PictographDataController.h
//  Pictograph
//
//  Created by Adam Boyd on 2015-10-19.
//  Copyright © 2015 Adam Boyd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CurrentUser.h"
#import <Google/Analytics.h>

@interface PictographDataController : NSObject

@property (nonatomic, strong) CurrentUser *user;
@property (nonatomic, strong) id<GAITracker> tracker;

+ (id)sharedController;

//Getting and setting information about the user
- (BOOL)getUserFirstTimeOpeningApp;
- (void)setUserFirstTimeOpeningApp:(BOOL)firstTime;
- (BOOL)getUserEncryptionEnabled;
- (void)setUserEncryptionEnabled:(BOOL)enabledOrNot;
- (NSString *)getUserEncryptionKey;
- (void)setUserEncryptionKey:(NSString *)newKey;
- (void)analyticsEncodeSend:(BOOL)encrypted;
- (void)analyticsDecodeSend:(BOOL)encrypted;
@end
