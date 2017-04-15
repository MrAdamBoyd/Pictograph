//
//  Global.h
//  Pictograph
//
//  Created by Adam Boyd on 17/4/14.
//  Copyright © 2017 Adam Boyd. All rights reserved.
//

#ifndef Global_h
#define Global_h

//Printing
#ifdef DEBUG
#define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define DLog(...) do {} while (0)
#endif

//Correct imports
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif


//Definitions
#if TARGET_OS_IPHONE
#define PictographImage UIImage
#define PictographColor UIColor
#else
#define PictographImage NSImage
#define PictographColor NSColor
#endif

#endif /* Global_h */
