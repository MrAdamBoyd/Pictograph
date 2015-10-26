//
//  ViewController.m
//  Pictograph
//
//  Created by Adam on 2015-09-30.
//  Copyright © 2015 Adam Boyd. All rights reserved.
//

#import "PictographMainViewController.h"
#import "Pictograph-Swift.h"

#define kButtonHeight 60
#define kMainAppColor [UIColor colorWithRed:220/255.0 green:0 blue:0 alpha:1]
#define kMainAppColorHighlighted [kMainAppColor colorWithAlphaComponent:0.5]
#define kButtonBorderWidth 0.5
#define kMainFontSize 20

#define kEncryptionMargin 40
#define kEncryptionVerticalMargin 40

//For the intro views
#define kIntroViewTitleFont [UIFont systemFontOfSize:35]
#define kIntroViewDescFont [UIFont systemFontOfSize:20]
#define kIntroViewTitleY [[UIScreen mainScreen] bounds].size.height - 50
#define kIntroViewDescY [[UIScreen mainScreen] bounds].size.height - 100
#define kIntroPage1Color [UIColor colorWithRed:24/255.0 green:120/255.0 blue:217/255.0 alpha:1]
#define kIntroPage2Color [UIColor colorWithRed:220/255.0 green:141/255.0 blue:56/255.0 alpha:1]

@interface PictographMainViewController ()

- (BOOL)setUpAndShowIntroViews;
- (void)setAlphaOfUIElementsTo:(CGFloat)alpha;
- (void)switchToggled:(id)sender;
- (void)encodeMessage;
- (void)decodeMessage;
- (void)promptUserForPhotoWithOptionForCamera:(BOOL)showCamera;
- (UIImagePickerController *)buildImagePickerWithSourceType:(UIImagePickerControllerSourceType)type;
- (void)startEncodingOrDecoding;
- (void)buildAndShowAlertWithTitle:(NSString *)title message:(NSString *)message isSecure:(BOOL)secureText withPlaceHolder:(NSString *)placeholder confirmHandler:(void (^ __nullable)(UIAlertAction *action))handler;
- (void)showShareSheetWithImage:(NSData *)image;
- (void)showMessageInAlertController:(NSString *)message withTitle:(NSString *)title;

@end

@implementation PictographMainViewController

@synthesize selectedImage;
@synthesize topBar;
@synthesize encryptionInfoViewBorder;
@synthesize encryptionLabel;
@synthesize encryptionSwitch;
@synthesize encryptionKeyField;
@synthesize encodeButton;
@synthesize decodeButton;
@synthesize currentOption;
@synthesize alertController;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Background color
    [self.view setBackgroundColor:kMainAppColor];
    
    //Nav bar
    topBar = [[PictographTopBar alloc] init];
    [topBar setBackgroundColor:kMainAppColor];
    [topBar setTranslatesAutoresizingMaskIntoConstraints:false];
    [self.view addSubview:topBar];
    
    //10px from top, 0px from left & right, 44px height
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:topBar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:10]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:topBar attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:topBar attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:topBar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:44]];
    
    
    //Encode button
    encodeButton = [[PictographHighlightButton alloc] init];
    [encodeButton addTarget:self action:@selector(encodeMessage) forControlEvents:UIControlEventTouchUpInside];
    [encodeButton setBackgroundColor:[UIColor whiteColor]];
    [encodeButton setTitleColor:kMainAppColor forState:UIControlStateNormal];
    [encodeButton setTitleColor:kMainAppColorHighlighted forState:UIControlStateHighlighted];
    [encodeButton setTitle:@"Hide Message" forState:UIControlStateNormal];
    [encodeButton setTranslatesAutoresizingMaskIntoConstraints:false];
    
    //Setting the border
    [encodeButton.layer setBorderColor:kMainAppColor.CGColor];
    [encodeButton.layer setBorderWidth:kButtonBorderWidth];
    
    [self.view addSubview:encodeButton];
    
    //-1px from left, 1px from bottom, 0px from center, 60px tall
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:encodeButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:1]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:encodeButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:-1]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:encodeButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:encodeButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:kButtonHeight]];
    
    
    //Decode button
    decodeButton = [[PictographHighlightButton alloc] init];
    [decodeButton addTarget:self action:@selector(decodeMessage) forControlEvents:UIControlEventTouchUpInside];
    [decodeButton setBackgroundColor:[UIColor whiteColor]];
    [decodeButton setTitleColor:kMainAppColor forState:UIControlStateNormal];
    [decodeButton setTitleColor:kMainAppColorHighlighted forState:UIControlStateHighlighted];
    [decodeButton setTitle:@"Reveal Message" forState:UIControlStateNormal];
    [decodeButton setTranslatesAutoresizingMaskIntoConstraints:false];

    //Setting the border
    [decodeButton.layer setBorderColor:kMainAppColor.CGColor];
    [decodeButton.layer setBorderWidth:kButtonBorderWidth];
    
    [self.view addSubview:decodeButton];
    
    //1px from bottom, 1px from right, 0px from center, 60px tall
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:decodeButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:1]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:decodeButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:decodeButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:1]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:decodeButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:kButtonHeight]];

    
    //Textfield where encryption key is stored
    encryptionKeyField = [[PictographTextField alloc] init];
    BOOL encryptionEnabled = [[PictographDataController sharedController] getUserEncryptionEnabled];
    [encryptionKeyField setAlpha:encryptionEnabled ? 1.0 : 0.5];
    [encryptionKeyField setEnabled:encryptionEnabled];
    [encryptionKeyField setDelegate:self];
    [encryptionKeyField setBackgroundColor:[UIColor whiteColor]];
    [encryptionKeyField setFont:[UIFont systemFontOfSize:kMainFontSize]];
    [encryptionKeyField setPlaceholder:@"Encryption Key"];
    [encryptionKeyField setText:[[PictographDataController sharedController] getUserEncryptionKey]];
    [encryptionKeyField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:encryptionKeyField];
    
    //50px from left, right, -20px (above) center y
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:encryptionKeyField attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:-kEncryptionVerticalMargin]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:encryptionKeyField attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:kEncryptionMargin]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:encryptionKeyField attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:-kEncryptionMargin]];
    
    
    
    //Label for enabling encryption
    encryptionLabel = [[UILabel alloc] init];
    [encryptionLabel setText:@"Use Password"];
    [encryptionLabel setFont:[UIFont boldSystemFontOfSize:kMainFontSize]];
    [encryptionLabel setTextColor:[UIColor whiteColor]];
    [encryptionLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:encryptionLabel];
    
    //0px from left, -20px (above) the top of encryptionKeyField
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:encryptionLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:kEncryptionMargin]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:encryptionLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:encryptionKeyField attribute:NSLayoutAttributeTop multiplier:1 constant:-kEncryptionVerticalMargin]];
    
    
    
    //Switch for enabling encryption
    encryptionSwitch = [[UISwitch alloc] init];
    [encryptionSwitch setOn:encryptionEnabled];
    [encryptionSwitch addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
    [encryptionSwitch setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:encryptionSwitch];
    
    //50px from right, center Y = encryptionLabel's center y
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:encryptionSwitch attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:-kEncryptionMargin]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:encryptionSwitch attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:encryptionLabel attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
 
    
    //Border between text label and switch for enabling and disabling encryption
    encryptionInfoViewBorder = [[UIView alloc] init];
    [encryptionInfoViewBorder setBackgroundColor:[UIColor whiteColor]];
    [encryptionInfoViewBorder setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:encryptionInfoViewBorder];
    
    //Halfway between the switch and the textfield, 40px from left, right, 1px tall
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:encryptionInfoViewBorder attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:encryptionKeyField attribute:NSLayoutAttributeTop multiplier:1 constant:-kEncryptionVerticalMargin / 2]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:encryptionInfoViewBorder attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:kEncryptionMargin - 10]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:encryptionInfoViewBorder attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:-kEncryptionMargin + 10]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:encryptionInfoViewBorder attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:1]];
    
    
    if ([self setUpAndShowIntroViews]) {
        //If intro views are shown, hide UI elements
        [self setAlphaOfUIElementsTo:0];
    }
     
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

//Touching anywhere on the screen so the textfield can resign first responder
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    
    //Saving the text
    [[PictographDataController sharedController] setUserEncryptionKey:encryptionKeyField.text];
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    //Saving the text
    [[PictographDataController sharedController] setUserEncryptionKey:textField.text];
    return NO;
}

#pragma mark EAIntroDelegate
- (void)introDidFinish:(EAIntroView *)introView {
    [[PictographDataController sharedController] setUserFirstTimeOpeningApp:NO];
    
    //Animating the views in
    [UIView animateWithDuration:1.f animations:^{
        [self setAlphaOfUIElementsTo:1.0];
    }];
}

#pragma mark Custom methods

//Shows the intro views if the user hasn't opened the app and/or if we don't have authorization to use gps
- (BOOL)setUpAndShowIntroViews {
    NSMutableArray<EAIntroPage *> *introViewArray = [[NSMutableArray alloc] init];
    
    if ([[PictographDataController sharedController] getUserFirstTimeOpeningApp]) {
        //Introducing the app
        EAIntroPage *page1 = [[EAIntroPage alloc] init];
        page1.title = @"Steganography";
        page1.titleFont = kIntroViewTitleFont;
        page1.titlePositionY = kIntroViewTitleY;
        page1.desc = @"Steganography is the practice of hiding messages.\n\nUsing Pictograph, you can hide messages in images, and the images won't look any different.";
        page1.descFont = kIntroViewDescFont;
        page1.descPositionY = kIntroViewDescY;
        page1.bgColor = kIntroPage1Color;
        [introViewArray addObject:page1];
        
        //Asking for permission for GPS while using the app
        EAIntroPage *page2 = [[EAIntroPage alloc] init];
        page2.title = @"Encryption";
        page2.titleFont = kIntroViewTitleFont;
        page2.titlePositionY = kIntroViewTitleY;
        page2.desc = @"Pictograph also allows you to encrypt your messages. You will have to give the password to whoever you want to read the message.";
        page2.descFont = kIntroViewDescFont;
        page2.descPositionY = kIntroViewDescY;
        page2.bgColor = kIntroPage2Color;
        [introViewArray addObject:page2];
    }
    
    if (introViewArray.count > 0) {
        CGRect frameRect = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height + 10);
        EAIntroView *introView = [[EAIntroView alloc] initWithFrame:frameRect];
        introView.pages = introViewArray;
        introView.delegate = self;
        [introView showInView:self.view animateDuration:0];
        
        //We did show intro views
        return YES;
    }
    
    //We didn't show any intro views
    return NO;
    
}

//Sets the alpha of all UI elements on screen
- (void)setAlphaOfUIElementsTo:(CGFloat)alpha {
    
    CGFloat keyFieldAlpha = alpha;
    if (alpha != 0) {
        //If the alpha is not 0, set the text entry field's alpha to the appropriate level
        BOOL encryptionEnabled = [[PictographDataController sharedController] getUserEncryptionEnabled];
        keyFieldAlpha = encryptionEnabled ? 1.0 : 0.5;
    }
    
    [topBar setAlpha:alpha];
    [encryptionInfoViewBorder setAlpha:alpha];
    [encryptionLabel setAlpha:alpha];
    [encryptionSwitch setAlpha:alpha];
    [encryptionKeyField setAlpha:keyFieldAlpha];
    [encodeButton setAlpha:alpha];
    [decodeButton setAlpha:alpha];
}

//Encryption enabled switch changed
- (void)switchToggled:(id)sender {
    UISwitch *mySwitch = (UISwitch *)sender;
    BOOL enabledOrDisabled = [mySwitch isOn];
    
    //Disabling or enabling the textfield based on whether encryption is enabled
    [encryptionKeyField setEnabled:enabledOrDisabled];
    
    //Animating the alpha of the textfield
    [UIView animateWithDuration:0.25 animations:^{
        [encryptionKeyField setAlpha:enabledOrDisabled ? 1.0 : 0.5];
    }];
    
    [[PictographDataController sharedController] setUserEncryptionEnabled:enabledOrDisabled];
}

//Starting the encode process
- (void)encodeMessage {
    /*
     True if encryption is enabled AND the key isn't blank
     OR encryption is disbled
     */
    if ((![[[PictographDataController sharedController] getUserEncryptionKey] isEqualToString:@""] && [[PictographDataController sharedController] getUserEncryptionEnabled]) || ![[PictographDataController sharedController] getUserEncryptionEnabled]) {
        //If the user has an encr
        currentOption = ImageOptionEncoder;
        [self promptUserForPhotoWithOptionForCamera:YES];
    } else {
        //Show message: encryption is enabled and key is blank
        [self showMessageInAlertController:@"Encryption is enabled but your key is blank, please enter a key." withTitle:@"No Encryption Key"];
    }
}

//Starting the decoding process
- (void)decodeMessage {
    currentOption = ImageOptionDecoder;
    [self promptUserForPhotoWithOptionForCamera:NO]; //Doesn't make sense to show the camera here
}

//Showing the action sheet
- (void)promptUserForPhotoWithOptionForCamera:(BOOL)showCamera {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] && showCamera) {
        //Device has camera & library, show option to choose
        alertController = [UIAlertController alertControllerWithTitle:@"Select Picture" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        //Cancel action
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) { /* No action needed */ }];
        [alertController addAction:cancelAction];
        
        //Library action
        UIAlertAction *libraryAction = [UIAlertAction actionWithTitle:@"Select from Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            //Choose photo from library, present library view controller
            UIImagePickerController *picker = [self buildImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            [self presentViewController:picker animated:YES completion:nil];
            
        }];
        [alertController addAction:libraryAction];
        
        //Take photo action
        UIAlertAction *takePhotoAction = [UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            //Take a photo
            UIImagePickerController *picker = [self buildImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
            [self presentViewController:picker animated:YES completion:nil];
            
        }];
        [alertController addAction:takePhotoAction];
        
        [self presentViewController:alertController animated:YES completion:^{}];
        
    } else {
        //Device has no camera, just show library
        UIImagePickerController *picker = [self buildImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        [self presentViewController:picker animated:YES completion:nil];
        
    }
}

//Builds a UIImagePickerController with source type
- (UIImagePickerController *)buildImagePickerWithSourceType:(UIImagePickerControllerSourceType)type {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = type;
    
    return picker;
}

//Encoding or decoding the selected image
- (void)startEncodingOrDecoding {
    
    if (currentOption == ImageOptionEncoder) {
        //Encoding the image with a message, need to get message
        
        [self buildAndShowAlertWithTitle:@"Enter your message" message:nil isSecure:NO withPlaceHolder:@"Your message here" confirmHandler:^(UIAlertAction *action) {
            
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            //Dispatching this task after a small amount of time as per MBProgressHUD's recommendations
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
                //Action that happens when confirm is hit
                UITextField *messageField = [alertController.textFields firstObject];
                
                UIImageCoder *coder = [[UIImageCoder alloc] init];
                NSError *error;
                
                NSData *encodedImage = [coder encodeImage:selectedImage withMessage:messageField.text encrypted:[[PictographDataController sharedController] getUserEncryptionEnabled] withPassword:[[PictographDataController sharedController] getUserEncryptionKey] error:&error];
                
                if (encodedImage) {
                    //Show the share sheet if the image exists
                    [self showShareSheetWithImage:encodedImage];
                
                } else {
                    //Showing the error, either the image was too small or the message was too big
                    [self showMessageInAlertController:[error localizedDescription] withTitle:@"Error"];
                }
                
                //Hiding the HUD
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        }];
        
    } else if (currentOption == ImageOptionDecoder) {
        //Decoding the image
        
        //No need to show HUD because this won't take long
        
        UIImageCoder *coder = [[UIImageCoder alloc] init];
        NSError *error;
        
        NSString *providedPassword = [encryptionSwitch isOn] ? encryptionKeyField.text : @""; //Provide no password if encryption/decryption is off
        NSString *decodedMessage = [coder decodeImage:selectedImage encryptedWithPassword:providedPassword error:&error];
        
        if (!error) {
            //If there is no error
            [self showMessageInAlertController:decodedMessage withTitle:@"Hidden Message"];
        } else {
            [self showMessageInAlertController:[error localizedDescription] withTitle:@"Error Decoding"];
        }
    }
}

//Building the alert that gets the message that the user should type
- (void)buildAndShowAlertWithTitle:(NSString *)title message:(NSString *)message isSecure:(BOOL)secureText withPlaceHolder:(NSString *)placeholder confirmHandler:(void (^ __nullable)(UIAlertAction *action))handler {
    
    alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    //Action for confirming the message
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:handler];
    [confirmAction setEnabled:false]; //Enabled or disabled based on text input
    [alertController addAction:confirmAction];
    
    
    //Action for cancelling
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    
    
    //Adding message field
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
         textField.placeholder = placeholder;
        textField.secureTextEntry = secureText;
        
        //Confirm is only enabled if there is text
        [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification object:textField queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            [confirmAction setEnabled:![[textField text] isEqualToString:@""]];
        }];
        
     }];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

//Shows the share sheet with the UIImage image
- (void)showShareSheetWithImage:(NSData *)image {
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[image] applicationActivities:nil];
    [self presentViewController:activityController animated:YES completion:nil];
}

//Shows the decoded message in an alert controller
- (void)showMessageInAlertController:(NSString *)message withTitle:(NSString *)title {
    alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:dismissAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark UIImagePickerControllerDelegate

//User picked image
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    selectedImage = chosenImage;
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    [self startEncodingOrDecoding];
}

//User cancelled
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    currentOption = ImageOptionNeither;
}

@end
