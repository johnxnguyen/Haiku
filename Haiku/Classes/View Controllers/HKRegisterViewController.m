//
//  HKRegisterViewController.m
//  Haiku
//
//  Created by John Nguyen on 10/12/2014.
//  Copyright (c) 2014 John Nguyen. All rights reserved.
//

#import "HKRegisterViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface HKRegisterViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextField *displayNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordConfirmTextField;

@property (strong, nonatomic) NSMutableData *imageData;
@property (strong, nonatomic) UIImage *profileImage;

@end

@implementation HKRegisterViewController



	#pragma mark USER INTERFACE
// ------------------------------------------------------------------------

// DONE BUTTON
//
- (IBAction)doneButtonTapped:(UIButton *)sender {
	
	// MAKE THUMBNAIL IMAGE
	
	if ([self isFormValid]) {
		
		// Sign up user
		PFUser *newUser = [[PFUser alloc] init];
		newUser[kHKUserDisplayName] = _displayNameTextField.text;
		newUser.username = _emailTextField.text;
		newUser.email = _emailTextField.text;
		newUser.password = _passwordTextField.text;
		
		if (_imageView.image)
			newUser[kHKUserImage] = [PFFile fileWithData:UIImageJPEGRepresentation(_imageView.image, 1.0)];
		
		[newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
			
			if (!error) {
				NSLog(@"User successfully signed up");
				[PFUser logOut];
				[self dismissViewControllerAnimated:YES completion:nil];
				
			} else {
				NSLog(@"Error: failed to sign up user, %@", error.userInfo);
				
				int code = (int)error.userInfo[@"code"];
				
				// taken username || taken email (username & email is the same)
				if (code == 202 || code == 203)
					[self alertUserWithMessage:@"An account is already registered with this email address."];
			}
		}];
	}
	
}

// CANCEL BUTTON
//
- (IBAction)cancelButtonTapped:(UIButton *)sender {
	
	[self dismissViewControllerAnimated:YES completion:nil];
}

// IMAGE BUTTON - select and image
//
- (IBAction)imageButtonTapped:(UIButton *)sender {
	
	// Action sheet
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Select Image"
																   message:nil
															preferredStyle:UIAlertControllerStyleActionSheet];
	
	// Camera action
	UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"Camera"
														   style:UIAlertActionStyleDefault
														 handler:^(UIAlertAction *action) {
															 
		 // If camera is available
		 if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
			 
			 UIImagePickerController *cameraController = [[UIImagePickerController alloc] init];
			 
			 // Set up controller
			 cameraController.delegate = self;
			 cameraController.sourceType = UIImagePickerControllerSourceTypeCamera;
			 [self presentViewController:cameraController animated:YES completion:nil];
			 
		 } else {
			 // Alert user
			 [self alertUserWithMessage:@"Couldn't open the camera. Please try again."];
		 }
	 }];
	
	// Library action
	UIAlertAction *libraryAction = [UIAlertAction actionWithTitle:@"Library"
															style:UIAlertActionStyleDefault
														  handler:^(UIAlertAction *action) {
															  
		  // If library is available
		  if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
			  
			  UIImagePickerController *libraryController = [[UIImagePickerController alloc] init];
			  
			  // Set up controller
			  libraryController.delegate = self;
			  libraryController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
			  [self presentViewController:libraryController animated:YES completion:nil];
			  
		  } else {
			  // Alert user
			  [self alertUserWithMessage:@"Couldn't open the photo library. Please try again."];
		  }
	  }];
	
	// Cancel action
	UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
														   style:UIAlertActionStyleCancel
														 handler:nil];
	
	[alert addAction:cameraAction];
	[alert addAction:libraryAction];
	[alert addAction:cancelAction];
	
	// On iPad & regular width devices, action sheets are displayed as Popovers.
	// If device is compact width, this returns nil
	UIPopoverPresentationController *popover = alert.popoverPresentationController;
	
	if (popover) {
		
		// Set popover params
		popover.sourceView = sender;
		popover.sourceRect = sender.bounds;
		popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
	}
	
	[self presentViewController:alert animated:YES completion:nil];
}



	#pragma mark IMAGE PICKER DELEGATE
// ------------------------------------------------------------------------

// DID FINISH PICKING
//
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	
	// Set image
	_profileImage = info[UIImagePickerControllerOriginalImage];
	_imageView.image = _profileImage;
	[self dismissViewControllerAnimated:YES completion:nil];
}


	#pragma mark HELPERS
// ------------------------------------------------------------------------

// IS FORM VALID
//
- (BOOL)isFormValid {
	
	if ([self isDisplayNameValid:_displayNameTextField.text])
		if ([self isEmailValid:_emailTextField.text])
			if ([self isPasswordValid:_passwordTextField.text])
				if ([_passwordTextField.text isEqualToString:_passwordConfirmTextField.text])
					return YES;
				else
					[self alertUserWithMessage:@"Passwords don't match."];
			else
				[self alertUserWithMessage:@"Please enter a valid password (8 - 16 alphanumeric characters."];
		else
			[self alertUserWithMessage:@"Please enter a valid email."];
	else
		[self alertUserWithMessage:@"Display name not valid (must be at least 1 char, can't start with a space)"];
	
	return NO;
}

// IS DISPLAY NAME VALID
//
- (BOOL)isDisplayNameValid:(NSString*)displayName {
	
	// cant begin with a space, at least 1 char long
	NSString *regExp = @"^[^\\s]+";
	NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regExp];
	return [test evaluateWithObject:displayName];
}

// IS EMAIL VALID
//
- (BOOL)isEmailValid:(NSString*)email {
	
	NSString *regExp = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
	NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regExp];
	return [test evaluateWithObject:email];
}

- (BOOL)isPasswordValid:(NSString*)password {
	
	// Password must be 8 - 15 chars long, alphnumeric
	NSString *regExp = @"[a-zA-Z0-9]{8,16}";
	NSPredicate *text = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regExp];
	return [text evaluateWithObject:password];
}

// ALERT USER
//
- (void)alertUserWithMessage:(NSString*)message {
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
													message:message
												   delegate:nil
										  cancelButtonTitle:@"Ok"
										  otherButtonTitles:nil];
	[alert show];
}


@end
