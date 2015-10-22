//
//  PictographDataController.m
//  Pictograph
//
//  Created by Adam Boyd on 2015-10-19.
//  Copyright © 2015 Adam Boyd. All rights reserved.
//

#import "PictographDataController.h"

#define kCurrentUserKey @"kCurrentUserKey"

@implementation PictographDataController

@synthesize user;

- (id)init {
    if (self = [super init]) {
        
        //Getting the current user
        NSData *unarchivedObject = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentUserKey];
        CurrentUser *newUser;
        
        if (unarchivedObject) {
            newUser = (CurrentUser *)[NSKeyedUnarchiver unarchiveObjectWithData:unarchivedObject];
        } else {
            //User doesn't exist, create one
            newUser = [[CurrentUser alloc] init];
        }
        user = newUser;
        
        [self saveCurrentUser];
    }
    
    return self;
}


# pragma mark Singleton methods

+ (id)sharedController {
    static PictographDataController *sharedController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedController = [[self alloc] init];
    });
    
    return sharedController;
}

# pragma mark CurrentUser methods

- (void)saveCurrentUser {
    NSData *archivedObject = [NSKeyedArchiver archivedDataWithRootObject:user];
    [[NSUserDefaults standardUserDefaults] setObject:archivedObject forKey:kCurrentUserKey];
}

- (BOOL)getUserFirstTimeOpeningApp {
    return user.firstTimeOpeningApp;
}

- (void)setUserFirstTimeOpeningApp:(BOOL)firstTime {
    [user setFirstTimeOpeningApp:firstTime];
    [self saveCurrentUser];
}

- (BOOL)getUserEncryptionEnabled {
    return user.encryptionEnabled;
}

- (void)setUserEncryptionEnabled:(BOOL)enabledOrNot {
    [user setEncryptionEnabled:enabledOrNot];
    [self saveCurrentUser];
}

- (NSString *)getUserEncryptionKey {
    return user.encryptionKey;
}

- (void)setUserEncryptionKey:(NSString *)newKey {
    [user setEncryptionKey:newKey];
    [self saveCurrentUser];
}

# pragma mark analytics methods
//Record a message encrypted event
- (void)analyticsEncodeSend:(BOOL)encrypted {
    NSString *encryptedOrNot = encrypted ? @"Encrypted" : @"Unencrypted";
    
    [Answers logCustomEventWithName:@"Encode Message"
                   customAttributes:@{@"Encryption" : encryptedOrNot}];
}

//Record a message decrypted event
- (void)analyticsDecodeSend:(BOOL)encrypted {
    NSString *encryptedOrNot = encrypted ? @"Encrypted" : @"Unencrypted";
    
    [Answers logCustomEventWithName:@"Encode Message"
                   customAttributes:@{@"Encryption" : encryptedOrNot}];
}

@end
