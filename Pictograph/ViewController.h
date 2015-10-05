//
//  ViewController.h
//  Pictograph
//
//  Created by Adam on 2015-09-30.
//  Copyright © 2015 Adam Boyd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIImage *selectedImage;
@property (nonatomic, strong) UIView *navBar;
@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) UIButton *encodeButton;
@property (nonatomic, strong) UIButton *decodeButton;

- (void)showChoosePhotoActionSheet;

@end

