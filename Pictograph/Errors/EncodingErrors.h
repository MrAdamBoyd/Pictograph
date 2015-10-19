//
//  EncodingErrors.h
//  Pictograph
//
//  Created by Adam Boyd on 2015-10-19.
//  Copyright © 2015 Adam Boyd. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *PictographErrorDomain = @"com.adam.Pictograph.ErrorDomain";

enum {
    ImageTooSmallError,
    MessageTooLongError,
    PasswordIncorrectError
};