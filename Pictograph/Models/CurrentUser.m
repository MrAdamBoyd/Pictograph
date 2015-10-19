//
//  CurrentUser.m
//  Pictograph
//
//  Created by Adam Boyd on 2015-10-19.
//  Copyright © 2015 Adam Boyd. All rights reserved.
//

#import "CurrentUser.h"

#define kFirstTimeOpeningAppKey @"kFirstTimeOpeningAppKey"
#define kEncryptionEnabledKey @"kEncryptionEnabledKey"
#define kEncryptionKey @"kEncryptionKey"

@implementation CurrentUser

@synthesize firstTimeOpeningApp;
@synthesize encryptionEnabled;
@synthesize encryptionKey;

- (id)init {
    if (self = [super init]) {
        firstTimeOpeningApp = YES;
        encryptionEnabled = NO;
        encryptionKey = @"";
    }
    
    return self;
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder {
    //We saved the bool as an NSNumber because BOOL types are not savable with an NSCoder
    NSNumber *firstTimeOpeningAppNumber = [aDecoder decodeObjectOfClass:[NSNumber class] forKey:kFirstTimeOpeningAppKey];
    firstTimeOpeningApp = [firstTimeOpeningAppNumber boolValue];
    
    NSNumber *encryptionEnabledNumber = [aDecoder decodeObjectOfClass:[NSNumber class] forKey:kEncryptionEnabledKey];
    encryptionEnabled = [encryptionEnabledNumber boolValue];
    
    encryptionKey = [aDecoder decodeObjectOfClass:[NSString class] forKey:kEncryptionKey];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    //First, convert the bool to an NSNumber
    NSNumber *firstTimeOpeningAppNumber = [[NSNumber alloc] initWithBool:firstTimeOpeningApp];
    [aCoder encodeObject:firstTimeOpeningAppNumber forKey:kFirstTimeOpeningAppKey];
    
    NSNumber *encryptionEnabledNumber = [[NSNumber alloc] initWithBool:encryptionEnabled];
    [aCoder encodeObject:encryptionEnabledNumber forKey:kEncryptionEnabledKey];
    
    [aCoder encodeObject:encryptionKey forKey:kEncryptionKey];
}

#pragma mark NSSecureCoding
+ (BOOL)supportsSecureCoding {
    return YES;
}

@end